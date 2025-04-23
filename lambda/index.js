const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const s3Client = new S3Client();

exports.handler = async (event) => {
    try {
        const message = JSON.parse(event.Records[0].Sns.Message);
        const timestamp = event.Records[0].Sns.Timestamp;
        
        // Extract domain from sourceArn
        const sourceArn = message.mail.sourceArn;
        const domain = sourceArn.split('/').pop();
        
        // Extract date components from timestamp (format: YYYY-MM-DDTHH:mm:ss.sssZ)
        const year = timestamp.substring(0, 4);
        const month = timestamp.substring(5, 7);
        const day = timestamp.substring(8, 10);
        
        // Default filename in case there is no email address
        let originalFilename = `${timestamp}-unknown-email`;
        
        // If the message contains email information, use the email address in the filename
        if (message.mail && message.mail.destination && message.mail.destination[0]) {
            originalFilename = `${timestamp}-${message.mail.destination[0]}`;
        }
        
        // Construct the final path
        const key = `${domain}/${message.notificationType}/${year}/${month}/${day}/${originalFilename}.json`;
        
        const params = {
            Bucket: process.env.BUCKET_NAME,
            Key: key,
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