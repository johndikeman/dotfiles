{
  config,
  lib,
  pkgs,
  # nixGL,
  ...
}:
let

  sources = import ./sources.nix;

  # what i'm doing to try to get this stupid fish-ai thing to work is insane
  src = pkgs.fetchFromGitHub {
    owner = "Realiserad";
    repo = "fish-ai";
    rev = "6d489f57704340fd43351dd85b941e8c5c49229f";
    sha256 = "adT8kQKiO7zD5EFHTjxofpj4sUvpu+nO+Atw/hZs0Gw=";
  };
  python = pkgs.python311;
  pythonPackages = python.pkgs;

  httpx = pythonPackages.httpx.overridePythonAttrs (old: rec {
    version = "0.27.0";
    src = pythonPackages.fetchPypi {
      pname = "httpx";
      inherit version;
      sha256 = "sha256-oMuIpG8y3IdOBO6VbkwnZKuiqiKPZQsGeIumvaKWKrU=";
    };
  });

  httpx-sse = pythonPackages.httpx-sse.overridePythonAttrs (old: rec {
    version = "0.4.0";
    src = pythonPackages.fetchPypi {
      pname = "httpx-sse";
      inherit version;
      sha256 = "sha256-HoGjowcM4yKt0dNSntQutfcIF/Re1uyRWrdT+WETlyE=";
    };
    dependencies = [ httpx ];
  });
  sslFix =
    pkg:
    pkg.overridePythonAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
        pkgs.cacert # Add CA certificates
      ];

      # Set certificate paths
      preConfigure =
        (old.preConfigure or "")
        + ''
          export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
        '';
    });

  # create a pinned pydantic-core derivation
  pydantic-core = pythonPackages.buildPythonPackage rec {
    pname = "pydantic_core";
    version = "2.20.1";
    pyproject = true;

    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "JsppXu7l+fGu6yEf/BLxC8tvceKYmYj9ph2r1l24eNQ=";
    };

    # patches = [ ./01-remove-benchmark-flags.patch ];

    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      name = "${pname}-${version}";
      hash = "sha256-faPM2hlJ2/UnXG+saFvk31lxyIYGIMY4QKTenWwIhS0=";
    };

    nativeBuildInputs = [
      pkgs.cargo
      pkgs.rustPlatform.cargoSetupHook
      pkgs.rustc
    ];

    build-system = [
      pkgs.rustPlatform.maturinBuildHook
      pythonPackages.typing-extensions
    ];

    buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.libiconv ];

    dependencies = [ pythonPackages.typing-extensions ];

    pythonImportsCheck = [ "pydantic_core" ];

    # escape infinite recursion with pydantic via dirty-equals
    doCheck = false;
    # passthru.tests.pytest = pydantic-core.overrideAttrs { doCheck = true; };

    nativeCheckInputs = [
      pkgs.pytestCheckHook
      pkgs.hypothesis
      pkgs.pytest-timeout
      pkgs.dirty-equals
      pkgs.pytest-mock
    ];

    disabledTests = [
      # RecursionError: maximum recursion depth exceeded while calling a Python object
      "test_recursive"
    ];

    disabledTestPaths = [
      # no point in benchmarking in nixpkgs build farm
      "tests/benchmarks"
    ];
  };
  pydantic = pythonPackages.pydantic.overridePythonAttrs (old: rec {
    version = "2.8.2";
    src = pythonPackages.fetchPypi {
      pname = "pydantic";
      inherit version;
      sha256 = "b2LBPQZ7B1WtHCGjS90GwMEmJaIrD8CcaxSYFmBPfCo=";
    };
    propagatedBuildInputs = [ pydantic-core ];
    dependencies = [
      pydantic-core
      pythonPackages.annotated-types
      pythonPackages.typing-extensions
    ];
  });

  mistralai = pythonPackages.buildPythonPackage rec {
    pname = "mistralai";
    version = "1.0.2";
    format = "pyproject";

    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "RvtEB9GkFhsj4bLExzVHhDP7ekGrsF+s0jJy+wXRcbU=";
    };
    propagatedBuildInputs = [
      pydantic
      (pythonPackages.buildPythonPackage rec {
        pname = "jsonpath-python";
        version = "1.0.6";
        format = "setuptools";
        src = pythonPackages.fetchPypi {
          inherit pname version;
          sha256 = "3Vvkpy2KKZXD9YPPgr880alUTP2r8tIllbZ6/wc0lmY=";
        };
      })
      pythonPackages.python-dateutil
      pythonPackages.typing-inspect
      httpx
    ];

    nativeBuildInputs = [
      pythonPackages.setuptools
      pythonPackages.wheel
      pythonPackages.poetry-core
    ];
  };
  # Create explicit dependency list with versions
  dependencies = [
    (pythonPackages.openai.overridePythonAttrs (old: rec {
      version = "1.60.0";
      src = pythonPackages.fetchPypi {
        pname = "openai";
        inherit version;
        sha256 = "sha256-f6U2zUtkRxhkW4dNJwbjbbvvOLMn5CygYjJ12jR+4ak=";
      };
      doCheck = false;
      postPatch = "";
      dependencies = [
        pydantic
        pythonPackages.anyio
        pythonPackages.distro
        # TODO: override the httpx version higher up
        httpx
        pythonPackages.jiter
        pythonPackages.sniffio
        pythonPackages.tqdm
        pythonPackages.typing-extensions
        pythonPackages.hatchling
      ];
    }))
    (pythonPackages.simple-term-menu.overridePythonAttrs (old: rec {
      version = "1.6.6";
      src = pythonPackages.fetchPypi {
        pname = "simple_term_menu";
        inherit version;
        sha256 = "mBPTb1dJ1i0gClWZseyIRpxxN4MSrcCEwAwAv7s4OJM=";
      };
    }))
    (sslFix (
      pythonPackages.buildPythonPackage rec {
        pname = "iterfzf";
        version = "1.4.0.54.3";
        format = "pyproject";
        __noChroot = true;

        src = pythonPackages.fetchPypi {
          inherit pname version;
          sha256 = "igudxPGhJtqVndYBZDvzHef6af67fDP0tuL6jtxL4uE="; # Replace with actual hash
        };

        nativeBuildInputs = [
          pythonPackages.flit-core
          pythonPackages.packaging
          pythonPackages.pyproject-hooks
          pkgs.fzf
        ];

        propagatedBuildInputs = [
          pythonPackages.typing-extensions
        ];

        # Needed for the custom build backend
        # preBuild = ''
        #  cp ${./build_dist.py} build_dist.py
        #  export FZF_PATH=${pkgs.fzf}/bin/fzf
        #'';

        # Disable tests that require network or external resources
        doCheck = false;

        meta = with lib; {
          description = "FZF-based interactive list UI for Python iterables";
          homepage = "https://github.com/ajalt/iterfzf";
          license = licenses.mit;
        };
      }
    ))
    (pythonPackages.buildPythonPackage rec {
      pname = "hugchat";
      version = "0.4.18";
      src = pythonPackages.fetchPypi {
        inherit pname version;
        sha256 = "OlAo0rSfBfU+UYXvkLErBzCQzdMGDiMjewxfzqYJbDE=";
      };
      propagatedBuildInputs = [ pythonPackages.requests ];
    })

    mistralai

    pythonPackages.binaryornot
    (pythonPackages.anthropic.overridePythonAttrs (old: rec {
      version = "0.45.0";
      doCheck = false;
      doInstallCheck = false;
      src = pythonPackages.fetchPypi {
        pname = "anthropic";
        inherit version;
        sha256 = "sha256-ToVB3DVTMgkL/FG4RUnBm2SaE6I9vWvWjh0BLghVECU=";
      };
      dependencies = [
        pythonPackages.anyio
        pythonPackages.distro
        httpx
        pythonPackages.jiter
        pythonPackages.sniffio
        pydantic
        pythonPackages.tokenizers
        pythonPackages.typing-extensions
      ];
    }))
    (pythonPackages.cohere.overridePythonAttrs (old: rec {
      version = "5.13.11";
      src = pythonPackages.fetchPypi {
        pname = "cohere";
        inherit version;
        sha256 = "hdLBoorIPTR5pcHKbN+Xu1J5RxTH/eBU65Ns/q+vV/Y=";
      };
      dependencies = [
        pythonPackages.fastavro
        httpx
        httpx-sse
        pythonPackages.parameterized
        pydantic
        pydantic-core
        pythonPackages.requests
        pythonPackages.tokenizers
        pythonPackages.types-requests
        pythonPackages.typing-extensions
      ];
    }))
  ];

  fish-ai = pythonPackages.buildPythonApplication {
    pname = "fish_ai";
    version = "1.0.3";
    inherit src;

    format = "pyproject";
    disabled = pythonPackages.pythonOlder "3.9";

    propagatedBuildInputs = dependencies;

    nativeBuildInputs = [
      pythonPackages.setuptools
      pythonPackages.pytest
      pythonPackages.pyfakefs
    ];

    # Add required system dependencies
    buildInputs = [
      pkgs.libffi
      pkgs.openssl
    ];

    # Verify the scripts are properly installed
    checkPhase = ''
      ${python.interpreter} -m pytest src/fish_ai/tests
    '';
  };
in

{
  home.packages = [ pkgs.fish ];

  programs.fish = {
    enable = true;
    generateCompletions = true;
    interactiveShellInit = "theme_gruvbox dark hard";
    plugins = [
      {
        name = "fish-ai";
        src = pkgs.fetchFromGitHub {
          owner = "Realiserad";
          repo = "fish-ai";
          rev = "6d489f57704340fd43351dd85b941e8c5c49229f";
          sha256 = "adT8kQKiO7zD5EFHTjxofpj4sUvpu+nO+Atw/hZs0Gw=";
        };
      }
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "a6bf0e5b9e356d57d666bc6def114f16f1e5e209";
          sha256 = "VC8LMjwIvF6oG8ZVtFQvo2mGdyAzQyluAGBoK8N2/QM=";
        };
      }
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
      {
        name = "fish-gruvbox";
        src = pkgs.fetchFromGitHub {
          owner = "Jomik";
          repo = "fish-gruvbox";
          rev = "master";
          sha256 = "RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
    ];
    functions = {
      # Chat aliases
      chatdev = {
        description = "Run chatdev agent";
        body = ''
          python test.py --modality=chat --agent=chat-dev --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      chatstable = {
        description = "Run chatstable agent";
        body = ''
          python test.py --modality=chat --agent=chat-stable --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      chathotfix = {
        description = "Run chathotfix agent";
        body = ''
          python test.py --modality=chat --agent=projects/att-aam-external/locations/global/agents/257be919-ecaa-4d4e-be63-0febfd51a740 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      chatdikeman1 = {
        description = "Run chatdikeman1 agent";
        body = ''
          python test.py --modality=chat --agent=dikeman1 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      chatdikeman2 = {
        description = "Run chatdikeman2 agent";
        body = ''
          python test.py --modality=chat --agent=dikeman2 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      chatdikeman5 = {
        description = "Run chatdikeman5 agent";
        body = ''
          python test.py --modality=chat --agent=projects/att-aam-external/locations/global/agents/d0230494-0a64-40df-9b21-d72d0c3da384 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      chatprod = {
        description = "Run chatprod agent";
        body = ''
          python test.py --modality=chat --agent=chat-prod --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };

      # Chat aliases without tests
      ntchatdev = {
        description = "Run chatdev agent without tests";
        body = ''
          python test.py --modality=chat --agent=chat-dev --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntchatstable = {
        description = "Run chatstable agent without tests";
        body = ''
          python test.py --modality=chat --agent=chat-stable --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntchathotfix = {
        description = "Run chathotfix agent without tests";
        body = ''
          python test.py --modality=chat --agent=projects/att-aam-external/locations/us-central1/agents/1a43ac5c-9789-4b56-b130-3a0cb10301c9 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntchatdikeman1 = {
        description = "Run chatdikeman1 agent without tests";
        body = ''
          python test.py --modality=chat --agent=dikeman1 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntchatdikeman2 = {
        description = "Run chatdikeman2 agent without tests";
        body = ''
          python test.py --modality=chat --agent=dikeman2 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntchatdikeman5 = {
        description = "Run chatdikeman5 agent without tests";
        body = ''
          python test.py --modality=chat --agent=projects/att-aam-external/locations/global/agents/d0230494-0a64-40df-9b21-d72d0c3da384 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntchatprod = {
        description = "Run chatprod agent without tests";
        body = ''
          python test.py --modality=chat --agent=chat-prod --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };

      # Voice aliases
      voicedikeman1 = {
        description = "Run voicedikeman1 agent";
        body = ''
          python test.py --modality=voice --agent=dikeman1 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      voicedikeman2 = {
        description = "Run voicedikeman2 agent";
        body = ''
          python test.py --modality=voice --agent=dikeman2 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      voicedikeman5 = {
        description = "Run voicedikeman5 agent";
        body = ''
          python test.py --modality=voice --agent=projects/att-aam-external/locations/global/agents/d0230494-0a64-40df-9b21-d72d0c3da384 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      voicestable = {
        description = "Run voicestable agent";
        body = ''
          python test.py --modality=voice --agent=voice-stable --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      voicehotfix = {
        description = "Run voicehotfix agent";
        body = ''
          python test.py --modality=voice --agent=projects/att-aam-external/locations/global/agents/b207eb43-87ae-4db9-bad6-92873b0e2705 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      voicemonthly = {
        description = "Run voicemonthly agent";
        body = ''
          python test.py --modality=voice --agent=projects/att-aam-external/locations/us-central1/agents/67ee16e5-9abd-4ff6-b319-6acde9b19bbe --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };
      voicehotfixbackup = {
        description = "Run voice-hotfix-backup agent";
        body = ''
          python test.py --modality=voice --agent=projects/att-aam-external/locations/global/agents/929d9559-b4b7-4654-9f89-3d5565310ca0 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs "$argv"
        '';
      };

      # Voice aliases without tests
      ntvoicedikeman1 = {
        description = "Run voicedikeman1 agent without tests";
        body = ''
          python test.py --modality=voice --agent=dikeman1 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntvoicedikeman2 = {
        description = "Run voicedikeman2 agent without tests";
        body = ''
          python test.py --modality=voice --agent=dikeman2 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntvoicedikeman5 = {
        description = "Run voicedikeman5 agent without tests";
        body = ''
          python test.py --modality=voice --agent=projects/att-aam-external/locations/global/agents/d0230494-0a64-40df-9b21-d72d0c3da384 --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntvoicestable = {
        description = "Run voicestable agent without tests";
        body = ''
          python test.py --modality=voice --agent=voice-stable --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntvoicehotfix = {
        description = "Run voicehotfix agent without tests";
        body = ''
          python test.py --modality=voice --agent=projects/att-aam-external/locations/us-central1/agents/865b5709-1e3d-4cf0-8399-4d301f3e9a1f --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntvoicemonthly = {
        description = "Run voicemonthly agent without tests";
        body = ''
          python test.py --modality=voice --agent=projects/att-aam-external/locations/us-central1/agents/67ee16e5-9abd-4ff6-b319-6acde9b19bbe --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };

      ntvoicegemini2 = {
        description = "Run gemini2 voice agent without tests";
        body = ''
          python test.py --modality=voice --agent=projects/att-aam-external/locations/us-east1/agents/a1cb3ef1-6203-485f-83e0-a8f88410e69f --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      ntchatgemini2 = {
        description = "Run gemini2 chat agent without tests";
        body = ''
          python test.py --modality=chat --agent=projects/att-aam-external/locations/us-east1/agents/aa58d207-5e50-4a23-9a0c-61e0da12fcae --repo_root=/usr/local/google/home/dikeman --gs_bucket=john-util --creds=/usr/local/google/home/dikeman/df-rm-scripts/creds.json --out_root=/usr/local/google/home/dikeman/df-rm-scripts-logs --run_tests=False "$argv"
        '';
      };
      # Utility alias
      gr = {
        description = "quickly reset your git repo";
        body = "git reset --hard && git clean -fdxq";
      };
      r = {
        description = "a handy way to accidentally nuke a directory and ruin your life";
        body = "rm -rf ./*";
      };
      scr = {
        description = "Change directory to df-rm-scripts and activate venv";
        body = ''
          cd ~/df-rm-scripts && source venv/bin/activate.fish
        '';
      };
      chat = {
        description = "Setup tmux session for att-golden-chat";
        body = ''
          tmux-setup ~/att-golden-chat/ $argv
        '';
      };

      voice = {
        description = "Setup tmux session for att-golden-chat";
        body = ''
          tmux-setup ~/ATT-Voice-Steering-Dev/ $argv
        '';
      };
      # Promote tickets by cherry-picking commits
      promote_tickets = {
        description = "Cherry-pick commits associated with given ticket codes to stable branch";
        body = ''
          set -l codes $argv[1]
          set -l regex (string join '\|' (string split ' ' $codes))
          set -l hashes (string split '\n' (git log --grep="$regex" --pretty=format:%H dev))
          set -l reversed_hashes

          for i in (seq (count $hashes) -1 1)
              set reversed_hashes $reversed_hashes $hashes[$i]
          end

          echo "Regex: $regex"
          echo "Hashes: $hashes"
          echo "Reversed Hashes: $reversed_hashes"

          git checkout stable
          git cherry-pick $reversed_hashes
        '';
      };

      # Revert tickets by reverting commits
      revert_tickets = {
        description = "Revert commits associated with given ticket codes on stable branch";
        body = ''
          set -l codes $argv[1]
          set -l regex (string join '\|' (string split ' ' $codes))
          set -l hashes (string split '\n' (git log --grep="$regex" --pretty=format:%H dev))

          git checkout stable
          git revert $hashes
        '';
      };

      # Core tmux setup function
      tmux-setup = {
        description = "Sets up a standard tmux development environment for a given path.";
        body = ''
          set -l path $argv[1]
          if test -z "$path"
              echo "Error: Path not provided to tmux-setup function."
              return 1
          end

          if not test -d "$path"
              echo "Error: '$path' is not a valid directory."
              return 1
          end

          # Check if a 'dev' session exists. If not, create it.
          if not tmux has-session -t dev > /dev/null 2>&1
              tmux new-session -s dev -d
          end

          # Create a new window within the 'dev' session
          tmux new-window -t dev -n "$path" # Name the window after the path

          # Split the new window vertically
          tmux split-window -v

          # Select the upper pane (index 0)
          tmux select-pane -t 0

          # Send the command to run lazygit
          tmux send-keys -t 0 "cd $path && lazygit" C-m

          # Select the lower pane (index 1)
          tmux select-pane -t 1

          # Split the lower pane horizontally
          tmux split-window -h

          # Select the bottom right pane (index 2 after splits)
          tmux select-pane -t 2
          tmux send-keys -t 2 "scr" C-m

          # Select the bottom left pane (index 1, then 0 after splitting, so it's pane 1 now)
          tmux select-pane -t 1

          # Send the command to run nvim
          tmux send-keys -t 1 "cd $path && nvim" C-m

          # Select the first window of the session
          tmux select-window -t dev:1

          # Attach to the session if not already attached
          if not tmux ls | grep -q 'dev:'
              tmux attach-session -t dev
          end
        '';
      };
      gdp = {
        description = "outputs a patch file for mergetwin to use";
        body = ''
          	function gdp --description "Generates a git diff patch for a specific voice file"
              # $argv[1] is the git hash
              # $argv[2] is the nine-digit code
              if test (count $argv) -ne 2
                  echo "Usage: gdp <hash> <nine_digit_code>"
                  return 1
              end

              set -l hash $argv[1]
              set -l code $argv[2]
              set -l output_dir ~/mergetwin/test/data/voice/
              set -l output_file "$output_dir"voice."$code"."$hash".test.patch

              # Create the directory if it doesn't exist
              mkdir -p -- "$output_dir"

              # Run the git diff command
              git diff "$hash"^.."$hash" > "$output_file"
              echo "Patch file created: $output_file"
          end
        '';
      };
    };
  };
  home.file = {
    ".fish-ai" = {
      source = fish-ai;
      recursive = true;
    };
  };
}
