
NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = $(HOME)/data
 
all:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) up -d --build
 
down:
	docker compose -f $(COMPOSE_FILE) down
 
clean: down
	docker compose -f $(COMPOSE_FILE) down --volumes --rmi all
 
fclean: clean
	sudo rm -rf $(DATA_DIR)/mariadb
	sudo rm -rf $(DATA_DIR)/wordpress
 
re: fclean all
 
.PHONY: all down clean fclean re