import SwiftUI

struct DownloadPopupView: View {
    @Binding var isPresented: Bool
    let downloadLinks: [DownloadLink]
    @State private var selectedLink: DownloadLink? = nil
    @State private var qrCodeImage: NSImage? = nil
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 24) {
                    Text("选择下载方式")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.controlBackgroundColor))
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .overlay(
                    Rectangle()
                        .fill(Color(.separatorColor))
                        .frame(height: 0.5)
                        .alignmentGuide(.bottom) { $0[.bottom] },
                    alignment: .bottom
                )
                
                if selectedLink == nil {
                    VStack(spacing: 12) {
                        ForEach(downloadLinks, id: \.provider) { link in
                            Button(action: {
                                selectedLink = link
                                generateQRCode(from: link.url)
                            }) {
                                HStack(spacing: 12) {
                                    if let diskInfo = DownloadConfig.netDisk[link.provider.lowercased()] {
                                        AsyncImage(url: URL(string: diskInfo.icon)) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 28, height: 28)
                                            } else {
                                                Image(systemName: "cloud.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        Text(diskInfo.name)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                    } else {
                                        Image(systemName: "cloud.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.blue)
                                        Text(link.provider)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color(.controlBackgroundColor))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                } else {
                    VStack(alignment: .center, spacing: 20) {
                        Text("扫描二维码下载")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if let image = qrCodeImage {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        } else {
                            ProgressView()
                                .scaleEffect(1.5)
                                .frame(width: 200, height: 200)
                        }
                        
                        if let link = selectedLink {
                            VStack(spacing: 8) {
                                Text("提取码: \(link.code)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Button(action: {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(link.code, forType: .string)
                                }) {
                                    Text("复制提取码")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Button(action: {
                            selectedLink = nil
                            qrCodeImage = nil
                        }) {
                            Text("返回选择")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                }
            }
            .background(Color(.windowBackgroundColor))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            .frame(maxWidth: 400)
            .padding(40)
        }
    }
    
    private func generateQRCode(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(urlString.data(using: .utf8), forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        if let outputImage = filter?.outputImage {
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            
            let context = CIContext()
            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                qrCodeImage = NSImage(cgImage: cgImage, size: NSSize(width: 200, height: 200))
            }
        }
    }
}
