extends Node3D

@export var mesh: MeshInstance3D
@export var outline_material: Material

func on_hover_enter():
  mesh.material_overlay = outline_material
  
func on_hover_exit():
  mesh.material_overlay = null
