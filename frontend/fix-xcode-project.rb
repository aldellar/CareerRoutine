#!/usr/bin/env ruby

# Script to add missing files to Xcode project programmatically
# 
# This script automatically adds Swift files from the filesystem to the Xcode project.
# It's useful when files are created outside of Xcode or when the project.pbxproj
# gets out of sync with the filesystem.
#
# Usage:
#   ruby fix-xcode-project.rb
#
# Prerequisites:
#   gem install xcodeproj --user-install
#
# The script will:
# 1. Open the Xcode project
# 2. Create missing groups (folders) in the project hierarchy
# 3. Add file references for each Swift file
# 4. Add files to the appropriate build phases (Sources)
# 5. Save the modified project
#
# After running this script:
# - Open the project in Xcode
# - Clean build folder (⌘⇧K)
# - Build the project (⌘B)

require 'xcodeproj'

PROJECT_PATH = 'ios/InterviewPrepApp/InterviewPrepApp.xcodeproj'
TARGET_NAME = 'InterviewPrepApp'

# Files to add (relative to InterviewPrepApp/ directory)
FILES_TO_ADD = {
  'Networking' => [
    'Networking/APIClient.swift',
    'Networking/APIError.swift',
    'Networking/APIError+Display.swift',
    'Networking/Config.swift',
    'Networking/Reachability.swift'
  ],
  'Networking/Models' => [
    'Networking/Models/APIPlan.swift',
    'Networking/Models/APIPrep.swift',
    'Networking/Models/APIProfile.swift'
  ],
  'ViewModels' => [
    'ViewModels/PrepViewModel.swift',
    'ViewModels/RerollViewModel.swift',
    'ViewModels/WeekViewModel.swift'
  ],
  'Utils' => [
    'Utils/AlertState.swift',
    'Utils/Loadable.swift'
  ]
}

def main
  puts "🔧 Opening Xcode project..."
  project = Xcodeproj::Project.open(PROJECT_PATH)
  
  target = project.targets.find { |t| t.name == TARGET_NAME }
  unless target
    puts "❌ Target '#{TARGET_NAME}' not found"
    exit 1
  end
  
  # Find the main group
  main_group = project.main_group.groups.find { |g| g.display_name == TARGET_NAME }
  unless main_group
    puts "❌ Main group '#{TARGET_NAME}' not found"
    exit 1
  end
  
  FILES_TO_ADD.each do |group_name, files|
    puts "\n📂 Processing group: #{group_name}"
    
    # Create or find the group
    group_parts = group_name.split('/')
    current_group = main_group
    
    group_parts.each do |part|
      existing = current_group.groups.find { |g| g.display_name == part }
      if existing
        current_group = existing
      else
        puts "   Creating group: #{part}"
        current_group = current_group.new_group(part, part)
      end
    end
    
    # Add files to the group
    files.each do |file_path|
      file_name = File.basename(file_path)
      
      # Check if file already exists in project
      existing_file = current_group.files.find { |f| f.display_name == file_name }
      if existing_file
        puts "   ⏭️  Skipping (already exists): #{file_name}"
        # Remove from build phase first to avoid duplicates
        target.source_build_phase.files.each do |build_file|
          if build_file.file_ref == existing_file
            target.source_build_phase.files.delete(build_file)
          end
        end
        current_group.files.delete(existing_file)
      end
      
      # Check if file exists on disk
      full_path = File.join('ios/InterviewPrepApp/InterviewPrepApp', file_path)
      unless File.exist?(full_path)
        puts "   ⚠️  File not found on disk: #{file_path}"
        next
      end
      
      # Add file reference with just the filename (group already has the path)
      file_ref = current_group.new_file(file_name)
      file_ref.path = file_name
      
      # Add to build phase
      target.source_build_phase.add_file_reference(file_ref)
      
      puts "   ✅ Added: #{file_name}"
    end
  end
  
  puts "\n💾 Saving project..."
  project.save
  
  puts "\n✨ Done! All files have been added to the Xcode project."
  puts "\nNext steps:"
  puts "1. Open the project in Xcode"
  puts "2. Clean build folder (⌘⇧K)"
  puts "3. Build the project (⌘B)"
rescue LoadError
  puts "❌ Error: 'xcodeproj' gem is not installed"
  puts "\nTo install, run:"
  puts "   gem install xcodeproj"
  puts "\nOr use sudo if needed:"
  puts "   sudo gem install xcodeproj"
  exit 1
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end

main

