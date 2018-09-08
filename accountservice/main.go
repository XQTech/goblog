package main

import (
	"flag"
	"fmt"

	"github.com/spf13/viper"

	"github.com/xqtech/goblog/accountservice/dbclient"
	"github.com/xqtech/goblog/accountservice/service"
	"github.com/xqtech/goblog/common/config"
	"github.com/xqtech/goblog/common/messaging"
)

var appName = "accountservice"

// Init function, runs before main()

func init() {

	// Read command line flags
	profile := flag.String("profile", "test", "Environment profile, something similar to spring profiles")
	configServerUrl := flag.String("configServerUrl", "http://configserver:8888", "Address to config server")
	configBranch := flag.String("configBranch", "master", "git branch to fetch configuration from")
	flag.Parse()

	// Pass the flag values into viper.
	viper.Set("profile", *profile)
	viper.Set("configServerUrl", *configServerUrl)
	viper.Set("configBranch", *configBranch)
}

func main() {
	fmt.Printf("Starting %v\n", appName)

	// NEW - load the config
	config.LoadConfigurationFromBranch(
		viper.GetString("configServerUrl"),
		appName,
		viper.GetString("profile"),
		viper.GetString("configBranch"))

	initializeBoltClient()
	initializeMessaging()
	go config.StartListener(appName, viper.GetString("amqp_server_url"), viper.GetString("config_event_bus"))
	service.StartWebServer(viper.GetString("server_port"))

	//service.StartWebServer("6868")
}

//Creates instance and calls the OpenBoltDb and Seed funcs
func initializeBoltClient() {
	service.DBClient = &dbclient.BoltClient{}
	service.DBClient.OpenBoltDb()
	service.DBClient.Seed()
}

// Call this from the main method.

func initializeMessaging() {

	if !viper.IsSet("amqp_server_url") {
		panic("No 'amqp_server_url' set in configuration, cannot start")
	}

	//log.println("is amqp_server_url set???-----" + viper.IsSet("amqp_server_url"))
	//log.println("amqp_server_url-----" + viper.GetString("amqp_server_url"))
	service.MessagingClient = &messaging.MessagingClient{}
	service.MessagingClient.ConnectToBroker(viper.GetString("amqp_server_url"))
	service.MessagingClient.Subscribe(viper.GetString("config_event_bus"), "topic", appName, config.HandleRefreshEvent)

}
