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

    cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
      inherit src;
      name = "${pname}-${version}";
      hash = "sha256-j9VAWV/AG+u52ji+erNUrdGX8kHlsOuYiBYbHzD0y8k=";
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
      pythonPackages.httpx
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
      dependencies = [
        pydantic
        pythonPackages.anyio
        pythonPackages.distro
        pythonPackages.httpx
        pythonPackages.jiter
        pythonPackages.sniffio
        pythonPackages.tqdm
        pythonPackages.typing-extensions
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
        pythonPackages.httpx
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
        pythonPackages.httpx
        pythonPackages.httpx-sse
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
  };
  home.file = {
    ".fish-ai" = {
      source = fish-ai;
      recursive = true;
    };
  };
}
