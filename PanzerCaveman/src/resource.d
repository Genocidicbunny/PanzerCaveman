module pzc.resource;

/*
	Implements all levels of file and resource access

	Format: {fs_name}://({path}{filename})|({nickname})

	fs_name - name of a mounted fs entry/archive. Specifies the fs handler that provides fs access via a unified interface

	path - in-archive path to a resource. For direct fs-mounted access, the path is relative to the mounted directory:
			mnt C:\example\foo1 foo1
			Now C:\example\foo1\bar\moo.exe is accessible via foo1://bar/moo (or bar\moo)

	filename - self explanatory?

	nickname - In the future may be used for loading packaged (archive + manifest) where the resource nickname is specified.


	Archive ---\	 /---|========|----\	  
				-----	 | Filter |		------| mount_archive |
	Folder ----/	 \---|========|----/	  

	Archives are effectively folders that can be mounted just the same as normal directories. Each archive is mounted under a fs_name prefix to a resource path

	FileSystem creates a virtual file system. The vfs provides effectively multiple search roots for a file. Currently the vfs requires the fs_name to be specified unless it is defaulted to file://
		which is mounted from the exec path of the process. You can manually specify file:// when accessing files. You can override the default mounting of file:// via a flag passed to FileSystem
		TODO :: filesystem changes should be monitored and signaled via callbacks	

	The resource system hooks in on top of FileSystem to provide resource loading. This means that the system will actually load a file and process it, returning a loaded resource objects, such as a Texture
	or a Sound or anything similar. 
		TODO :: resource system should listen for file changes and reload resources during runtime. 

*/


private:


public:


class Archive {



}

class ArchiveFilter {

}

class FileSystem {

}