$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'mittsu'
require 'mittsu/mesh_analysis'
require 'mittsu/opengl'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

scene = Mittsu::Scene.new
camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)

renderer = Mittsu::OpenGL::Renderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: 'Rendering Winged Edge Meshes'

geometry = Mittsu::MeshAnalysis::WingedEdgeGeometry.new
geometry.from_geometry(Mittsu::TorusGeometry.new(1.0, 0.4, 12, 32))

# Render as wireframe AND as a shaded surface so that we can still see holes
material = Mittsu::MeshLambertMaterial.new(color: 0xffff00, wireframe: true)
knot1 = Mittsu::Mesh.new(geometry, material)
scene.add(knot1)
material = Mittsu::MeshLambertMaterial.new(color: 0x00ff00)
knot2 = Mittsu::Mesh.new(geometry, material)
scene.add(knot2)

light = Mittsu::DirectionalLight.new(0xffffff, 1)
light.position.set(0.9, 0.9, 1)
light_object = Mittsu::Object3D.new
light_object.add(light)
scene.add(light_object)

ambient = Mittsu::AmbientLight.new(0x3f3f3f)
ambient_object = Mittsu::Object3D.new
ambient_object.add(ambient)
scene.add(ambient_object)


camera_container = Mittsu::Object3D.new
camera_container.add(camera)
camera.position.z = 5.0
scene.add(camera_container)

renderer.window.on_resize do |width, height|
  renderer.set_size(width, height)
  camera.aspect = width.to_f / height.to_f
  camera.update_projection_matrix
end

X_AXIS = Mittsu::Vector3.new(1.0, 0.0, 0.0)
Y_AXIS = Mittsu::Vector3.new(0.0, 1.0, 0.0)
mouse_delta = Mittsu::Vector2.new
last_mouse_position = Mittsu::Vector2.new

renderer.window.on_mouse_button_pressed do |button, position|
  if button == GLFW::MOUSE_BUTTON_LEFT
    last_mouse_position.copy(position)
  end
end

renderer.window.on_mouse_move do |position|
  if renderer.window.mouse_button_down?(GLFW::MOUSE_BUTTON_LEFT)
    mouse_delta.copy(last_mouse_position).sub(position)
    last_mouse_position.copy(position)
    camera_container.rotate_on_axis(Y_AXIS, mouse_delta.x * 0.01)
    camera_container.rotate_on_axis(X_AXIS, mouse_delta.y * 0.01)
  end
end


renderer.window.run do
  renderer.render(scene, camera)
end
