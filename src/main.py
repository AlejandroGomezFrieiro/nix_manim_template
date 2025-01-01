import manim
import numpy as np

class CreateCircle(manim.Scene):
    def construct(self):
        circle = manim.Circle()  # create a circle
        circle.set_fill(manim.PINK, opacity=0.5)  # set the color and transparency
        self.play(manim.Create(circle))  # show the circle on screen


