package service

import (
	"github.com/gorilla/mux"
)

func NewRouter() *mux.Router {

	//Create an instance of the Gorilla router
	router := mux.NewRouter().StrictSlash(true)

	//Iterate over the routes we declared in routes.go
	//and attach them to the router instance
	for _, route := range routes {
		router.Methods(route.Method).
			Path(route.Pattern).
			Name(route.Name).
			Handler(route.HandlerFunc)
	}
	return router
}
