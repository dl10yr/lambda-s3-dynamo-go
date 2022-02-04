package main

import (
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

type Request struct {
	ID   float64 `json: "id"`
	Name string  `json: "name"`
	Like string  `json: "like"`
}

type Response struct {
	YouName string `json: "name"`
	YouLike string `json: "like"`
}

func Handler(request Request) (Response, error) {
	return Response{
		YouName: fmt.Sprintf("あなたはID %f 番 %s です。", request.ID, request.Name),
		YouLike: fmt.Sprintf("あなたの好きな物は %s です", request.Like),
	}, nil
}

func main() {
	lambda.Start(Handler)
}
