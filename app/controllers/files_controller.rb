# ----------------------------------------------------------------------------------------------------
# Author: Mai Mizuno
# Description:
# The script is designed to display file names, their paths and contents of
# a specified directory if the .docx files in the directory contain SSN.
# It also allows the user to upload files in to the specified directory.
# ----------------------------------------------------------------------------------------------------

require 'search_in_file'

class FilesController < ApplicationController

  # SSN search in the specified directory's .docx files
  def new_1511679
    if params[:path].present?
      @s_path = params[:path].to_s  # file path provided by the user on the web
      @s_path = @s_path.gsub!("\"", "") if @s_path =~ /"/ # if the path contains "", remove them
      @contents = []  # array to store files and content containing SSNs
      @s_error = ""
      ssn_pattern = /\b[A-Za-z0-9]{3}-[A-Za-z0-9]{2}-[A-Za-z0-9]{4}\b/  # SSN format: xxx-xx-xxxx (x: alphanumeric, no special chars)

      begin
        # search for all .docx files in the dir and sub-dirs and store the objs in the array
        @all_docx_array = SearchInFile.find_by_type_in(@s_path, ".docx")

        # iterate over each element(file) in the array
        @all_docx_array.each do |file|
          content = SearchInFile.content_of(file)
          # add files containing SSN to the @contents array
          if content =~ ssn_pattern
            ssn_array = content.scan(ssn_pattern)
            @contents << { file: file, content: content, ssn: ssn_array}
          end
        end

        # save the file details in the S3Fileapp model for all matching files
        if @contents.present?
          @contents.each do |file|
            record = S3Fileapp.new(
              name: file[:file].gsub("/", "\\"),
              content: file[:content],
              ssn: file[:ssn].join(", ")
            )
            record.save
          end
        end

        # store an error message in the @error var if there are no SSN matches
        @s_error = "No SSNs found in the given directory." if @contents.empty?

      # handle an error for an inappropriate path provided
      rescue Errno::ENOENT => e
        Rails.logger.error "Failed to search for files: #{e.message}"
        @s_error = "The directory does not exist. Please check the path and try again."
      # handle other errors
      rescue => e
        Rails.logger.error "Failed to search for files: #{e.message}"
        @s_error = "An unexpected error occurred. Please try again."
      end
    end
  end

  # File upload
  def upload_1511679
    uploaded_file = params[:u_file]  # file provided by the user on the web
    @u_path = (params[:u_path])  # file path provided by the user on the web
    @u_path = @u_path.gsub!("\"", "") if @u_path =~ /"/ # if the path contains "", remove them
    @u_path.gsub("/", "\\") if RUBY_PLATFORM =~ /win|mingw/ # convert / to \ if the user's platform is windows

    # check if both file and path are provided
    if uploaded_file.present? && @u_path.present?
      begin
        # create the directory if it doesn't exist
        FileUtils.mkdir_p(@u_path)

        # open the file in write-binary mode and save the uploaded content
        File.open(File.join(@u_path, uploaded_file.original_filename), 'wb') do |file|
          file.write(uploaded_file.read)
          # set flash notice after successful upload of the file
          flash[:notice] = "File uploaded successfully to #{@u_path}!"
        end

      rescue => e
        Rails.logger.error "Failed to save file: #{e.message}"
        # set flash alert if an error occurred
        flash[:alert] = "An error occurred while saving the file. Please try again."
      end
    else
      # set flash alert if no proper file/path is provided
      flash[:alert] = "Please select a file and enter a valid path."
    end

    #redirect to the previous page
    redirect_to new_1511679_path

  end

end
