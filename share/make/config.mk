print: FORCE
	@$(ECHO) $($(VAR))
FORCE:

print-name-and-value: FORCE
	@$(ECHO) $(VAR) = $($(VAR))
