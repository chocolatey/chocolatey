module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    watch: {
      ps1: {
		files: ['**/*.ps1'],
		tasks: ['copy:ps1']
	  },
	  psm1: {
	    files: ['**/*.psm1'],
		tasks: ['copy:psm1']
	  }
    },
	copy: {
		ps1: {
			files: [				
				{expand: true, cwd: 'src/', src: ['**/*.ps1'], dest: '/chocolatey/chocolateyinstall'}
			]
		},
		psm1: {
			files: [				
				{expand: true, cwd: 'src/', src: ['**/*.psm1'], dest: '/chocolatey/chocolateyinstall'}
			]
		}
	}
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.registerTask('default', ['watch']);

};