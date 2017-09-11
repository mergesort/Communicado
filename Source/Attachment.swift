import Foundation

/// An Attachment which can be used
public struct Attachment {
    
    /// The attachment type for this attachment, passed as a MIME type.
    public let attachmentType: AttachmentType
    
    /// The filename as it will be transmitted in the attachment.
    public let filename: String
    
    /// The data which will be transmitted in the attachment.
    public let data: Data
    
    public init(attachmentType: AttachmentType, filename: String, data: Data) {
        self.attachmentType = attachmentType
        self.filename = filename
        self.data = data
    }
    
}
