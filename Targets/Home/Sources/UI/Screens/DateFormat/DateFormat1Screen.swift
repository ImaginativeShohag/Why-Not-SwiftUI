//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI

/// If we have [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) date format then we can use: `ISO8601DateFormatter`.
///
/// WWDC2020: [Formatters: Make data human-friendly](https://developer.apple.com/videos/play/wwdc2020/10160/?time=140).
struct DateFormat1Screen: View {
    @State private var selectedDate = Date.now
    @State private var formatText = "EEEE, MMM d, yyyy"
    @State private var selectedLocale: LocaleData = .init(id: "en_US_POSIX", name: "English")
    
    var locales: [LocaleData] = Locale.availableIdentifiers.map {
        let name = (NSLocale.current as NSLocale)
            .displayName(forKey: .languageCode, value: $0) ?? "-"
        
        return LocaleData(id: $0, name: name)
    }.sorted(by: \.id)
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLocale.id)
        formatter.dateFormat = formatText
        return formatter
    }

    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    DatePicker(
                        selection: $selectedDate,
                        displayedComponents: .date
                    ) {
                        Text(NSLocalizedString("select_a_date_picker_label", bundle: .module, comment: ""))
                            .font(.headline)
                    }
                    
                    DatePicker(
                        selection: $selectedDate,
                        displayedComponents: .hourAndMinute
                    ) {
                        Text(NSLocalizedString("select_a_time_picker_label", bundle: .module, comment: ""))
                            .font(.headline)
                    }
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary)
                }
                
                HStack {
                    Text(NSLocalizedString("time_examples_section_header", bundle: .module, comment: ""))
                        .font(.headline)
                    
                    Spacer()
                    
                    Picker(NSLocalizedString("choose_a_locale", bundle: .module, comment: ""), selection: $selectedLocale) {
                        ForEach(locales, id: \.id) {
                            Text("\($0.id) (\($0.name))")
                                .tag($0)
                                .lineLimit(1)
                        }
                    }
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("format_text", bundle: .module, comment: ""))
                        .font(.headline)
                    
                    TextField(NSLocalizedString("format_text", bundle: .module, comment: ""), text: $formatText)
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
                
                Text(NSLocalizedString("select_a_date_label", bundle: .module, comment: ""))
                    .font(.title)
                
                ExampleItem(
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateFormat: "EEEE, MMM d, yyyy"
                )
                
                ExampleItem(
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateFormat: "MM/dd/yyyy"
                )
                
                ExampleItem(
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateFormat: "MM-dd-yyyy HH:mm"
                )
                
                ExampleItem(
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateFormat: "MMM d, h:mm a"
                )
                
                ExampleItem(
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateFormat: "MMMM yyyy"
                )
                
                ExampleItem(
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateFormat: "MMM d, yyyy"
                )
                
                ExampleItem(
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateFormat: "E, d MMM yyyy HH:mm:ss Z"
                )
                
                ExampleItem(
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ"
                )
                
                ExampleItem(
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateFormat: "dd.MM.yy"
                )
                
                ExampleItem(
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateFormat: "HH:mm:ss.SSS"
                )
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("date_format", bundle: .module, comment: ""))
    }
}

struct DateFormat1Screen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DateFormat1Screen()
        }
    }
}

// MARK: - Components

private struct ExampleItem: View {
    let date: Date
    let locale: String
    let dateFormat: String
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale)
        formatter.dateFormat = dateFormat
        return formatter
    }
    
    var body: some View {
        VStack {
            Text(dateFormat)
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
