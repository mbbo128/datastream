######################
### Docker compose ###
######################

reload: down up

up:
	@docker-compose up -d; \
	echo "\nThe elastic cluster is running at http://localhost:9201"; \

down:
	@docker-compose down --remove-orphans; \