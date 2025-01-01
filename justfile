render:
    manim -qh ./src/main.py

shell:
    nix develop . --no-pure-eval
