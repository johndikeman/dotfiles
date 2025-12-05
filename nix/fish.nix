{
  config,
  lib,
  pkgs,
  # nixGL,
  ...
}:
let

  sources = import ./sources.nix;

in

{
  home.packages = [ pkgs.fish ];

  programs.fish = {
    enable = true;
    generateCompletions = true;
    interactiveShellInit = "theme_gruvbox dark hard";
    plugins = [
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

      revert_tickets_voice = {
        description = "Revert commits associated with given ticket codes on stable branch";
        body = ''
          set -l codes $argv[1]
          set -l regex (string join '\|' (string split ' ' $codes))
          set -l hashes (string split '\n' (git log --grep="$regex" --pretty=format:%H))

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
  };
}
