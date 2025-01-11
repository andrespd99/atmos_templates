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

# Añadir un PBXShellScriptBuildPhase para copiar el archivo plist de Firebase
shell_script_phase_name = "Copy GoogleService-Info.plist file"
existing_phase = target.shell_script_build_phases.find { |phase| phase.name == shell_script_phase_name }

unless existing_phase
  shell_script_phase = target.new_shell_script_build_phase(shell_script_phase_name)
  shell_script_phase.shell_path = "/bin/sh"
  shell_script_phase.shell_script = <<~SCRIPT
    environment="default"

    # Extract the scheme name from the Build Configuration
    if [[ $CONFIGURATION =~ -([^-]*)$ ]]; then
      environment=${BASH_REMATCH[1]}
    fi

    echo $environment

    # Define the resource path
    GOOGLESERVICE_INFO_PLIST=GoogleService-Info.plist
    GOOGLESERVICE_INFO_FILE=${PROJECT_DIR}/config/${environment}/${GOOGLESERVICE_INFO_PLIST}

    # Ensure the plist file exists
    echo "Looking for ${GOOGLESERVICE_INFO_PLIST} in ${GOOGLESERVICE_INFO_FILE}"
    if [ ! -f $GOOGLESERVICE_INFO_FILE ]; then
      echo "No GoogleService-Info.plist found. Please ensure it's in the proper directory."
      exit 1
    fi

    # Define the destination path
    PLIST_DESTINATION=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app
    echo "Will copy ${GOOGLESERVICE_INFO_PLIST} to final destination: ${PLIST_DESTINATION}"

    # Copy the file
    cp "${GOOGLESERVICE_INFO_FILE}" "${PLIST_DESTINATION}"
  SCRIPT
end

# Guardar los cambios en el proyecto
project.save
