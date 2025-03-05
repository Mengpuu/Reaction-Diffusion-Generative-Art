import com.jogamp.opengl.GL2;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.DwShadertoy;

DwPixelFlow context;
DwShadertoy toy, toyA, toyB, toyC, toyD;

int uFrameRate = 150;

void settings() {
  size(800, 800, P2D);
  smooth(0);
}

void setup() {
  // Enable window resizing
  surface.setResizable(true);

  // Initialize PixelFlow context
  context = new DwPixelFlow(this);
  context.print();
  context.printGL();

  // Initialize Shadertoy buffers for reaction-diffusion simulation
  toyA = new DwShadertoy(context, "shaders/ReactionDiffusion_BufferA.glsl");
  toyB = new DwShadertoy(context, "shaders/ReactionDiffusion_BufferB.glsl");
  toyC = new DwShadertoy(context, "shaders/ReactionDiffusion_BufferC.glsl");
  toyD = new DwShadertoy(context, "shaders/ReactionDiffusion_BufferD.glsl");
  toy  = new DwShadertoy(context, "shaders/ReactionDiffusion_Image.glsl");

  println(PGraphicsOpenGL.OPENGL_VENDOR);
  println(PGraphicsOpenGL.OPENGL_RENDERER);
  frameRate(uFrameRate);
}

void draw() {
  blendMode(REPLACE);

  // Apply reaction-diffusion stages sequentially
  toyA.set_iChannel(0, toyD);
  toyA.apply(width, height);

  toyB.set_iChannel(0, toyA);
  toyB.apply(width, height);

  toyC.set_iChannel(0, toyB);
  toyC.apply(width, height);

  toyD.set_iChannel(0, toyC);
  toyD.apply(width, height);

  // Render final image
  toy.set_iChannel(0, toyD);
  toy.apply(this.g);

  // Display frame information in window title
  String txt_fps = String.format(getClass().getSimpleName() + "   [size %d/%d]   [frame %d]   [fps %6.2f]", width, height, frameCount, frameRate);
  surface.setTitle(txt_fps);

}

void keyReleased(){
  if(key == 's') saveFrame("grayscott.jpg");
}
