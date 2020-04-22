component {

	function compile(path) {
		var pageSource = getPageContext().getPageSource(path);

		//compile
		getPageContext().compile(pageSource);

		var className = pageSource.getJavaName();
		var classDir = pageSource.getMapping().getClassRootDirectory();
		var classPath = replace(className, ".", "/", "ALL");

		var fullClassPath = classDir & classPath & ".class";
		if (fileExists(fullClassPath)) {
			return fullClassPath;
		} else {
			throw(message="Compiled class was not in the expected location: #fullClassPath#");
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
				errors.append({path:f, message:e.message});
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