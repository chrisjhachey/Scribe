#!/usr/bin/env bash 
set -xe

# install packages and dependencies
go get github.com/dgrijalva/jwt-go
go get github.com/go-sql-driver/mysql
go get github.com/gorilla/mux

# build command
go build -o bin/application application.go
