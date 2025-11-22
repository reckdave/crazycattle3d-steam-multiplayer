extends Node

func set_processes(node: Node, enabled: bool) -> void :
    node.set_process(enabled)
    node.set_physics_process(enabled)
    node.set_process_unhandled_input(enabled)
    node.set_process_input(enabled)
