package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
	"time"
)

const ipfs = "ipfs://QmVg3VuNLvVno2aiKK1q617EKZvuJk2WjEaKfSsNGhHJmN"

var TrumpInaguration = time.Date(2017, time.January, 20, 12, 0, 0, 0, time.UTC)
var BidenInaguration = time.Date(2021, time.January, 20, 12, 0, 0, 0, time.UTC)
var COINAPI_KEY = os.Getenv("COINAPI_KEY")

type Attribute struct {
	TraitType string `json:"trait_type"`
	Value     string `json:"value"`
}

type Metadata struct {
	Name        string      `json:"name"`
	Description string      `json:"description"`
	Image       string      `json:"image"`
	Attributes  []Attribute `json:"attributes"`
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func main() {
	files, err := os.ReadDir("img/tokens")
	check(err)

	tokenID := 0
	for _, f := range files {
		name := f.Name()
		// remove extension
		name = strings.Split(name, ".")[0]
		if strings.HasSuffix(name, "_crop") || name == "" {
			continue
		}
		name = strings.ReplaceAll(name, "_", "-")

		t, err := time.Parse("2006-01-02", name)
		check(err)

		president := "Obama"
		if t.After(TrumpInaguration) {
			president = "Trump"
		}
		if t.After(BidenInaguration) {
			president = "Biden"
		}

		tokenID += 1
		m := Metadata{
			Image:       fmt.Sprintf("%s/%s", ipfs, f.Name()),
			Name:        fmt.Sprintf("SHOW RECEIPT #%d", tokenID),
			Description: fmt.Sprintf("Welcome to the United States of America! Please show this receipt to exit. This is a receipt from %s commemorating your entry into the country.", t.Format("January 2, 2006")),
			Attributes: []Attribute{
				{
					TraitType: "Year",
					Value:     t.Format("2006"),
				},
				{
					TraitType: "President",
					Value:     president,
				},
				{
					TraitType: "ETH Price",
					Value:     getEthPrice(t),
				},
			},
		}

		println(t.String())

		j, err := json.MarshalIndent(m, "", "  ")
		check(err)

		f, err := os.Create(fmt.Sprintf("./metadata/%d", tokenID))

		_, err = f.WriteString(string(j))
		check(err)
		defer f.Close()
	}
}

func getEthPrice(d time.Time) string {
	client := &http.Client{}

	req, err := http.NewRequest("GET", fmt.Sprintf("https://rest.coinapi.io/v1/exchangerate/ETH/USD?time=%s", d.Format("2006-01-02")), nil)
	check(err)
	req.Header.Set("X-CoinAPI-Key", COINAPI_KEY)

	resp, err := client.Do(req)
	check(err)

	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	check(err)

	var data map[string]interface{}
	err = json.Unmarshal(body, &data)
	check(err)
	println(string(body))

	return fmt.Sprintf("$%.2f", data["rate"])
}
