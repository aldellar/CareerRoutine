#!/usr/bin/env ruby

# Script to remove duplicate/incorrect file references from Xcode project
# This cleans up any incorrectly added files so we can start fresh

require 'xcodeproj'

PROJECT_PATH = 'ios/InterviewPrepApp/InterviewPrepApp.xcodeproj'

def main
  puts "🧹 Cleaning up Xcode project..."
  project = Xcodeproj::Project.open(PROJECT_PATH)
  
  files_to_remove = [
    'APIClient.swift',
    'APIError.swift',
    'APIError+Display.swift',
    'Config.swift',
    'Reachability.swift',
    'APIPlan.swift',
    'APIPrep.swift',
    'APIProfile.swift',
    'PrepViewModel.swift',
    'RerollViewModel.swift',
    'WeekViewModel.swift',
    'AlertState.swift',
    'Loadable.swift'
  ]
  
  removed_count = 0
  
  # Find all file references with these names and remove them
  project.files.each do |file_ref|
    if files_to_remove.include?(file_ref.display_name)
      # Remove from all build phases
      project.targets.each do |target|
        target.source_build_phase.files.each do |build_file|
          if build_file.file_ref == file_ref
            target.source_build_phase.files.delete(build_file)
            puts "   Removed from build phase: #{file_ref.display_name}"
          end
        end
      end
      
      # Remove the file reference
      file_ref.remove_from_project
      removed_count += 1
      puts "   ✅ Removed: #{file_ref.display_name}"
    end
  end
  
  # Also remove the empty groups if they exist
  main_group = project.main_group.groups.find { |g| g.display_name == 'InterviewPrepApp' }
  if main_group
    ['Networking', 'ViewModels'].each do |group_name|
      group = main_group.groups.find { |g| g.display_name == group_name }
      if group && group.children.empty?
        group.remove_from_project
        puts "   🗑️  Removed empty group: #{group_name}"
      end
    end
  end
  
  puts "\n💾 Saving project..."
  project.save
  
  puts "\n✨ Cleanup complete! Removed #{removed_count} file references."
  puts "\nNow add the files manually through Xcode:"
  puts "1. Open: ios/InterviewPrepApp/InterviewPrepApp.xcodeproj"
  puts "2. Right-click 'InterviewPrepApp' folder in the navigator"
  puts "3. Select 'Add Files to InterviewPrepApp...'"
  puts "4. Navigate to: ios/InterviewPrepApp/InterviewPrepApp/"
  puts "5. Select these folders (⌘-click to multi-select):"
  puts "   - Networking (the whole folder)"
  puts "   - ViewModels (the whole folder)"
  puts "6. In the dialog, ensure these options are checked:"
  puts "   ✓ 'Create groups' (NOT 'Create folder references')"
  puts "   ✓ 'InterviewPrepApp' target"
  puts "   ✓ 'Copy items if needed' (unchecked - files are already in place)"
  puts "7. Click 'Add'"
  puts "8. Repeat steps 2-7 to add individual files from Utils:"
  puts "   - Utils/AlertState.swift"
  puts "   - Utils/Loadable.swift"
  puts "9. Clean build folder (⌘⇧K)"
  puts "10. Build (⌘B)"
  
rescue LoadError
  puts "❌ Error: 'xcodeproj' gem is not installed"
  exit 1
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end

main

