import Foundation

/// Commonly supported attachment types
public enum AttachmentType {
    
    case aiff
    case avi
    case gif
    case html
    case jpg
    case mov
    case mp3
    case mp4
    case pdf
    case plainText
    case png
    case psd
    case rtf
    case tiff
    case zip
    
    /// Any identifier which is not one of the common ones encapsulated in this `AttachmentType`s.
    case custom(value: String)
    
    var identifier: String {
        switch self {
            
        case .aiff:
            return "audio/aiff"
            
        case .avi:
            return "video/avi"
            
        case .gif:
            return "image/gif"
            
        case .html:
            return "text/html"
            
        case .jpg:
            return "image/jpeg"
            
        case .mov:
            return "video/quicktime"
            
        case .mp3:
            return "audio/mp3"
            
        case .mp4:
            return "video/mp4"
            
        case .pdf:
            return "application/pdf"
            
        case .plainText:
            return "text/plain"
            
        case .png:
            return "image/png"
            
        case .psd:
            return "image/psd"
            
        case .rtf:
            return "text/rtf"
            
        case .tiff:
            return "image/tiff"
            
        case .zip:
            return "application/zip"
            
        case .custom(let value):
            return value
            
        }
    }
    
}
