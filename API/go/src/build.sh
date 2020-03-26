#!/usr/bin/env bash 
set -xe

# install packages and dependencies
go get github.com/dgrijalva/jwt-go
go get github.com/go-sql-driver/mysql
go get github.com/gorilla/mux
go get github.com/chrisjhachey/Scribe/tree/UserAuth/API/go/src/api

# build command
go build -o bin/application application.go
