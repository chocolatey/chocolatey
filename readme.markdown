#Chocolatey - Cache Additions

This allows one to use a website directory structure as a repository source. The repository source is crawled and cached locally so that NuGet can reference it as a local file system.

For more information on chocolatey, please see the original project, [chocolatey](https://github.com/chocolatey/chocolatey) and the [wiki](https://github.com/chocolatey/chocolatey/wiki)

##Quick Start
Will give more information on the structuring of the actual website directory. For now, however, given a website directory of http://files.lambyhat.com/repository

Get a copy of a temporarily modified chocolatey (you may have to issue a ```Set-ExecutionPolicy Unrestricted``` first):
```sh
> Powershell "iex ((new-object net.webclient).DownloadString('http://files.lambyhat.com/chocolatey/installChocolatey.ps1'))"
```

Add in the repository:
```sh
> choco sources add -name test -type cache -source http://files.lambyhat.com/repository
```

Tell chocolatey to crawl it and cache the nupkg files from it locally:
```sh
> choco sources update
```

After that, installation of packages is the same as normal. Chocolatey will do a fix-up of the source to tell NuGet to point to the local cache whenever your search, list or install packages.

## Credits
See [docs/legal/CREDITS](https://github.com/chocolatey/chocolatey/raw/master/docs/legal/CREDITS) (just LEGAL/Credits in the zip folder)  
