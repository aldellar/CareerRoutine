#!/usr/bin/env ruby

# Script to fix incorrect file paths in Xcode project
# This directly fixes the path references without using the xcodeproj gem's file manipulation

require 'xcodeproj'

PROJECT_PATH = 'ios/InterviewPrepApp/InterviewPrepApp.xcodeproj'
TARGET_NAME = 'InterviewPrepApp'

def main
  puts "🔧 Opening Xcode project..."
  project = Xcodeproj::Project.open(PROJECT_PATH)
  
  target = project.targets.find { |t| t.name == TARGET_NAME }
  unless target
    puts "❌ Target '#{TARGET_NAME}' not found"
    exit 1
  end
  
  main_group = project.main_group.groups.find { |g| g.display_name == TARGET_NAME }
  unless main_group
    puts "❌ Main group '#{TARGET_NAME}' not found"
    exit 1
  end
  
  # Remove all incorrectly added files first
  puts "\n🧹 Removing incorrectly added files..."
  networking_group = main_group.groups.find { |g| g.display_name == 'Networking' }
  viewmodels_group = main_group.groups.find { |g| g.display_name == 'ViewModels' }
  utils_group = main_group.groups.find { |g| g.display_name == 'Utils' }
  
  [networking_group, viewmodels_group].compact.each do |group|
    files_to_remove = group.files + group.recursive_children.select { |c| c.is_a?(Xcodeproj::Project::Object::PBXFileReference) }
    files_to_remove.each do |file_ref|
      # Remove from build phases
      target.source_build_phase.files.each do |build_file|
        if build_file.file_ref == file_ref
          target.source_build_phase.files.delete(build_file)
        end
      end
    end
    group.clear
    group.remove_from_project
    puts "   ✅ Removed group: #{group.display_name}"
  end
  
  # Remove AlertState and Loadable from Utils if they exist
  if utils_group
    ['AlertState.swift', 'Loadable.swift'].each do |filename|
      file_ref = utils_group.files.find { |f| f.display_name == filename }
      if file_ref
        target.source_build_phase.files.each do |build_file|
          if build_file.file_ref == file_ref
            target.source_build_phase.files.delete(build_file)
          end
        end
        file_ref.remove_from_project
        puts "   ✅ Removed from Utils: #{filename}"
      end
    end
  else
    utils_group = main_group.groups.find { |g| g.display_name == 'Utils' }
  end
  
  # Now add files correctly
  puts "\n📂 Adding files with correct paths..."
  
  # Create Networking group
  networking_group = main_group.new_group('Networking', 'Networking')
  ['APIClient.swift', 'APIError.swift', 'APIError+Display.swift', 'Config.swift', 'Reachability.swift'].each do |filename|
    file_ref = networking_group.new_reference(filename)
    target.source_build_phase.add_file_reference(file_ref)
    puts "   ✅ Added: Networking/#{filename}"
  end
  
  # Create Networking/Models group
  models_group = networking_group.new_group('Models', 'Models')
  ['APIPlan.swift', 'APIPrep.swift', 'APIProfile.swift'].each do |filename|
    file_ref = models_group.new_reference(filename)
    target.source_build_phase.add_file_reference(file_ref)
    puts "   ✅ Added: Networking/Models/#{filename}"
  end
  
  # Create ViewModels group
  viewmodels_group = main_group.new_group('ViewModels', 'ViewModels')
  ['PrepViewModel.swift', 'RerollViewModel.swift', 'WeekViewModel.swift'].each do |filename|
    file_ref = viewmodels_group.new_reference(filename)
    target.source_build_phase.add_file_reference(file_ref)
    puts "   ✅ Added: ViewModels/#{filename}"
  end
  
  # Add to Utils group
  if utils_group
    ['AlertState.swift', 'Loadable.swift'].each do |filename|
      file_ref = utils_group.new_reference(filename)
      target.source_build_phase.add_file_reference(file_ref)
      puts "   ✅ Added: Utils/#{filename}"
    end
  end
  
  puts "\n💾 Saving project..."
  project.save
  
  puts "\n✨ Done! All files have been added with correct paths."
  puts "\nNext steps:"
  puts "1. Open the project in Xcode"
  puts "2. Clean build folder (⌘⇧K)"
  puts "3. Build the project (⌘B)"
  
rescue LoadError
  puts "❌ Error: 'xcodeproj' gem is not installed"
  exit 1
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end

main

