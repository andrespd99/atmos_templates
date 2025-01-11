require 'xcodeproj'

# Ruta al archivo .xcodeproj (actualiza esto con tu ruta)
project_path = 'ios/Runner.xcodeproj'

# Ruta de la carpeta que deseas agregar (relativa al proyecto)
folder_path = 'config'

# Abrir el proyecto
project = Xcodeproj::Project.open(project_path)

# Crear una nueva referencia para la carpeta si no existe
folder_reference = project.files.find { |file| file.path == folder_path }
unless folder_reference
  folder_reference = project.new_file(folder_path)
  folder_reference.last_known_file_type = 'folder'
end

# Agregar la referencia al grupo raíz del proyecto si no está ya en `children`
main_group = project.main_group
unless main_group.children.include?(folder_reference)
  main_group << folder_reference
end

# Buscar el target y la fase de recursos donde debe agregarse la carpeta
target = project.targets.first # Cambia esto si tienes múltiples targets
resources_phase = target.resources_build_phase

# Crear una entrada en la sección de recursos si no existe
existing_build_file = resources_phase.files.find { |file| file.file_ref == folder_reference }
unless existing_build_file
  build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  build_file.file_ref = folder_reference
  resources_phase.files << build_file
end

# Guardar los cambios en el proyecto
project.save
