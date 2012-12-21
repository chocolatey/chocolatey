# Some files have a changing element/hash in the download path, making an automated download harder.
# This file gets the correct download url from a download page with a regular expression.
# Good for e.g. Foobar2000, Rename Master, etc
#
# Usage: Get-FilenameFromRegex download_page find replace
# Examples:
# Get-FilenameFromRegex "http://www.joejoesoft.com/vcms/hot/userupload/8/files/rmv303.zip" '/cms/file.php\?f=userupload/8/files/rmv303.zip&amp;c=([\w\d]+)' 'http://www.joejoesoft.com/sim/$1/userupload/8/files/rmv303.zip'
#
# Remember to escape regex characters, like the question mark in the querystring

function Get-FilenameFromRegex {
	param(
		[string]$source_url, 
		[string]$find,
		[string]$replace
	)

	try {

		## Example # $source_url = "http://www.joejoesoft.com/vcms/hot/userupload/8/files/rmv303.zip"
		## Example # $find = '/cms/file.php\?f=userupload/8/files/rmv303.zip&amp;c=([\w\d]+)'
		## Example # $replace = 'http://www.joejoesoft.com/sim/$1/userupload/8/files/rmv303.zip'		

		# Download and open download page
		$tempfile = "chocolatey_temp_download.html"
		$wc = new-object system.net.webclient
		$wc.UseDefaultCredentials = $true
		$wc.downloadfile($source_url, $tempfile)
		$source = Get-Content $tempfile
		
		$nothing = ''+$source -cmatch $find # Get the matches, prevent output
		# Replace Match-references with previous matches: $1 $2 -> $matches[1] $matches[2]
		#$download_url = $replace -creplace "\$`(\d+)",$matches[$1]
		# This one is not working :(
		# I have a temporary fix that only allows ONE match. However, in most cases we only need one match.
		$download_url = $replace -creplace "\$`(\d+)",$matches[1]

		return $download_url
		
	} catch {
		$errorMessage = "Could not get Regex from download page."
		Write-Error $errorMessage
		throw $errorMessage
  }
}
