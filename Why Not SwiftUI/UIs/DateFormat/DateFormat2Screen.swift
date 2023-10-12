//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

/// Date field symbol table: https://unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table
struct DateFormat2Screen: View {
    @State private var formatText = "yyyyMMMMddHHmmssZ"
    
    var locales: [LocaleData] = Locale.availableIdentifiers.map {
        let name = (NSLocale.current as NSLocale)
            .displayName(forKey: .languageCode, value: $0) ?? "-"
        
        return LocaleData(id: $0, name: name)
    }.sorted(by: \.id)
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Format Text")
                    .font(.headline)
                
                TextField("Format Text", text: $formatText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1)
            }
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.secondary)
            }
            .padding()
            
            Divider()
            
            ScrollView {
                LazyVStack {
                    ForEach(locales, id: \.id) { locale in
                        ExampleItem(
                            date: Date(),
                            locale: locale,
                            dateTemplate: formatText
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Date Format using Template")
    }
}

struct DateFormat2Screen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DateFormat2Screen()
        }
    }
}

private struct ExampleItem: View {
    let date: Date
    let locale: LocaleData
    let dateTemplate: String
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale.id)
        
        // MARK: - START

        formatter.setLocalizedDateFormatFromTemplate(dateTemplate)
        
        // Or, (below code will do the same)
        
        // formatter.dateFormat = DateFormatter.dateFormat(
        //     fromTemplate: dateTemplate,
        //     options: 0,
        //     locale: Locale(identifier: locale.id)
        // )

        // MARK: END -
        
        return formatter
    }
    
    var body: some View {
        VStack {
            Text("\(locale.id) (\(locale.name))")
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity)
            
            Text("\(dateFormatter.string(from: date))")
                .font(.system(.body, design: .monospaced))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.5))
                }
        }
        .foregroundColor(.white)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
        }
    }
}
