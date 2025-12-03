## Generate using
##   prefixes <- c("CPP", "C", "CXX", "F", "FC", "OBJC", "OBJCXX")
##   writeLines(c(sprintf("\t@echo PKG_%sFLAGS: \"$(PKG_%sFLAGS)\"",
##                        prefixes, prefixes),
##                sprintf("\t@echo %sFLAGS: \"$(%sFLAGS)\"",
##                        prefixes, prefixes)))

makevars_test:
	@$(ECHO) PKG_CPPFLAGS: "$(PKG_CPPFLAGS)"
	@$(ECHO) PKG_CFLAGS: "$(PKG_CFLAGS)"
	@$(ECHO) PKG_CXXFLAGS: "$(PKG_CXXFLAGS)"
	@$(ECHO) PKG_FFLAGS: "$(PKG_FFLAGS)"
	@$(ECHO) PKG_FCFLAGS: "$(PKG_FCFLAGS)"
	@$(ECHO) PKG_OBJCFLAGS: "$(PKG_OBJCFLAGS)"
	@$(ECHO) PKG_OBJCXXFLAGS: "$(PKG_OBJCXXFLAGS)"
	@$(ECHO) CPPFLAGS: "$(CPPFLAGS)"
	@$(ECHO) CFLAGS: "$(CFLAGS)"
	@$(ECHO) CXXFLAGS: "$(CXXFLAGS)"
	@$(ECHO) FFLAGS: "$(FFLAGS)"
	@$(ECHO) FCFLAGS: "$(FCFLAGS)"
	@$(ECHO) OBJCFLAGS: "$(OBJCFLAGS)"
	@$(ECHO) OBJCXXFLAGS: "$(OBJCXXFLAGS)"
