component {

	function compile(path) {
		var pageSource = getPageContext().getPageSource(path);

		//compile
		getPageContext().compile(pageSource);

		var className = pageSource.getJavaName();
		var classDir = pageSource.getMapping().getClassRootDirectory();
		// Newer versions of Lucee use the format
		// cfclasses\CFC__path_to_web_root/path/to/file_cfm$cf.class
		var classPath = replace(className, ".", "/", "ALL");
		// Older versions of Lucee use this format
		// cfclasses\CFC__path_to_web_root/path.to.file_cfm$cf.class
		var classPath2 = replace(className, "/", ".", "ALL");
		var classPath2 = replace(classPath2, ".", "/", "ONCE");

		var fullClassPath = classDir & classPath & ".class";
		var fullClassPath2 = classDir & classPath2 & ".class";
		
		// Check behind door number 1
		if (fileExists(fullClassPath)) {
			return fullClassPath;
		// Check behind door number 2
		} else if(fileExists(fullClassPath2)) {
			return fullClassPath2;
		// Give up
		} else {
			throw(message="Compiled class was not in the expected location: #fullClassPath# or #fullClassPath2#");
		}
	}

	function compileDirectory(source, dest, extensionFilter) {
		var dir = directoryList(arguments.source, true, "path", extensionFilter);
		var f = "";
		var errors = [];
		//var mappings = {"/compile/"=getDirectoryFromPath(arguments.source)};
		//cfapplication(name="cfmlcompiler", mappings="#mappings#");
		
		for (f in dir) {
			try {
				var relativePath = replaceNoCase(f, source, "");
				var classFile = compile(relativePath);
				var destDir = getDirectoryFromPath(relativePath);
				if (!directoryExists(arguments.dest & destDir)) {
					directoryCreate(arguments.dest & destDir, true);
				}
				fileCopy(classFile, arguments.dest & relativePath);
			} catch (any e) {
				errors.append({path:f&':'&e.tagContext[1].line, message:e.message});
			}
		}
		return errors;
	}

	remote string function compiler(string source, string dest, string accessKey="", string extensionFilter="*.cfm|*.cfc" ) {
		var sysAccessKey = createObject("java", "java.lang.System").getProperty("cfmlcompilerkey");
		if (arguments.accessKey != sysAccessKey) {
			throw(message="Access Denied");
		}
		var errors = compileDirectory(source, dest, extensionFilter);
		if (arrayLen(errors)) {
			return "Errors: #serializeJSON(errors)#";
		}
		return "done";
	}

	remote string function serviceUp() {
		return "UP";
	}
}