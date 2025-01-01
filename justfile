render:
        manim -ql ./src/main.py

shell:
    nix develop . --no-pure-eval
