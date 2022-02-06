package main

import (
	"bufio"
	"context"
	"log"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/s3"
)

type Response struct {
	BucketName string `json:"bucketName"`
	Key        string `json:"key"`
	Size       int64  `json:"size"`
	StatusCode int    `json:"statusCode"`
}

type Member struct {
	id     string
	name   string
	gender string
	team   string
}

func genDbRequests(members []Member) []*dynamodb.WriteRequest {
	requests := []*dynamodb.WriteRequest{}
	for _, member := range members {
		requests = append(requests, &dynamodb.WriteRequest{
			PutRequest: &dynamodb.PutRequest{
				Item: map[string]*dynamodb.AttributeValue{
					"id": {
						S: aws.String(member.id),
					},
					"name": {
						S: aws.String(member.name),
					},
					"gender": {
						S: aws.String(member.gender),
					},
					"team": {
						S: aws.String(member.team),
					},
				},
			},
		})
	}
	return requests
}

func update(members []Member, db *dynamodb.DynamoDB) {
	tableName := os.Getenv("DYNAMO_TABLE")

	requests := genDbRequests(members)
	params := &dynamodb.BatchWriteItemInput{
		RequestItems: map[string][]*dynamodb.WriteRequest{
			tableName: requests,
		},
	}

	obj, err := db.BatchWriteItem(params)
	if err != nil {
		log.Fatal(err)
	}
	log.Println("obj: ", obj)
}

func ReadS3Csv(s3client *s3.S3, bucketName string, objectKey string) ([]Member, error) {
	members := []Member{}
	obj, err := s3client.GetObject(&s3.GetObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(objectKey),
	})
	if err != nil {
		log.Fatal(err)
	}
	data := obj.Body
	defer data.Close()
	scanner := bufio.NewScanner(data)

	for scanner.Scan() {
		RowStrs := strings.Split(scanner.Text(), ",")
		members = append(members, Member{
			id:     RowStrs[0],
			name:   RowStrs[1],
			gender: RowStrs[2],
			team:   RowStrs[3],
		})
	}
	return members, nil
}

func Handler(ctx context.Context, event events.S3Event) (interface{}, error) {
	response := Response{}
	region := "ap-northeast-1"

	sess := session.Must(session.NewSession())
	db := dynamodb.New(sess, aws.NewConfig().WithRegion(region))
	s3client := s3.New(sess)

	for _, record := range event.Records {
		members, read_err := ReadS3Csv(s3client, record.S3.Bucket.Name, record.S3.Object.Key)
		if read_err != nil {
			log.Fatal(read_err)
		}
		log.Println("members: ", members)

		update(members, db)
	}
	response.StatusCode = 200
	log.Println("response: ", response)
	return response, nil
}

func main() {
	lambda.Start(Handler)
}

// eventの生データを出力する
// func (h *RawHandler) Invoke(ctx context.Context, payload []byte) ([]byte, error) {
// 	log.Println(string(payload))
// }

// func main() {
// 	lambda.StartHandler(&RawHandler{})
// }
