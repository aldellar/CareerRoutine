#!/usr/bin/env ruby

# Script to remove duplicate file references from build phases

require 'xcodeproj'

PROJECT_PATH = 'ios/InterviewPrepApp/InterviewPrepApp.xcodeproj'

def main
  puts "🧹 Removing duplicate build file references..."
  project = Xcodeproj::Project.open(PROJECT_PATH)
  
  project.targets.each do |target|
    seen_files = {}
    files_to_remove = []
    
    target.source_build_phase.files.each do |build_file|
      if build_file.file_ref
        file_path = build_file.file_ref.real_path.to_s
        
        if seen_files[file_path]
          files_to_remove << build_file
          puts "   Found duplicate: #{build_file.file_ref.display_name}"
        else
          seen_files[file_path] = true
        end
      end
    end
    
    files_to_remove.each do |build_file|
      target.source_build_phase.files.delete(build_file)
      puts "   ✅ Removed duplicate: #{build_file.file_ref.display_name}"
    end
  end
  
  puts "\n💾 Saving project..."
  project.save
  
  puts "\n✨ Done!"
  
rescue LoadError
  puts "❌ Error: 'xcodeproj' gem is not installed"
  exit 1
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end

main

