const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const s3Client = new S3Client();

exports.handler = async (event) => {
    try {
        const message = JSON.parse(event.Records[0].Sns.Message);
        const timestamp = event.Records[0].Sns.Timestamp;
        
        // Default filename in case there is no email address
        let filename = `${timestamp}-unknown-email.json`;
        
        // If the message contains email information, use the email address in the filename
        if (message.mail && message.mail.destination && message.mail.destination[0]) {
            filename = `${timestamp}-${message.mail.destination[0]}.json`;
        }
        
        const params = {
            Bucket: process.env.BUCKET_NAME,
            Key: filename,
            Body: JSON.stringify(message),
            ContentType: 'application/json'
        };
        
        await s3Client.send(new PutObjectCommand(params));
        
        return {
            statusCode: 200,
            body: JSON.stringify('SES notification has been saved in S3')
        };
    } catch (error) {
        console.error('Error during processing notification:', error);
        throw error;
    }
}; 