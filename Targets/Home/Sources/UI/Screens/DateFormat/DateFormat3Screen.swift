//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI

struct DateFormat3Screen: View {
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
                        Text("Select a date")
                            .font(.headline)
                    }
                    
                    DatePicker(
                        selection: $selectedDate,
                        displayedComponents: .hourAndMinute
                    ) {
                        Text("Select a time")
                            .font(.headline)
                    }
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary)
                }
                
                HStack {
                    Text("Locale")
                        .font(.headline)
                    
                    Spacer()
                    
                    Picker("Choose a locale", selection: $selectedLocale) {
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
                
                Text("Result")
                    .font(.title)
                
                // MARK: - Only Date
                
                Text("Date Examples")
                    .font(.title2)
                
                ExampleItem(
                    dateLabel: ".full",
                    timeLabel: ".none",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .full,
                    timeStyle: .none
                )
                
                ExampleItem(
                    dateLabel: ".long",
                    timeLabel: ".none",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .long,
                    timeStyle: .none
                )
                
                ExampleItem(
                    dateLabel: ".medium",
                    timeLabel: ".none",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .medium,
                    timeStyle: .none
                )
                
                ExampleItem(
                    dateLabel: ".short",
                    timeLabel: ".none",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .short,
                    timeStyle: .none
                )
                
                // MARK: - Only Time
                
                Text("Time Examples")
                    .font(.title2)
                
                ExampleItem(
                    dateLabel: ".none",
                    timeLabel: ".full",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .none,
                    timeStyle: .full
                )
                
                ExampleItem(
                    dateLabel: ".none",
                    timeLabel: ".long",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .none,
                    timeStyle: .long
                )
                
                ExampleItem(
                    dateLabel: ".none",
                    timeLabel: ".medium",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .none,
                    timeStyle: .medium
                )
                
                ExampleItem(
                    dateLabel: ".none",
                    timeLabel: ".short",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .none,
                    timeStyle: .short
                )
                
                // MARK: - Date & Time
                
                Text("Date & Time Examples")
                    .font(.title2)
                
                ExampleItem(
                    dateLabel: ".full",
                    timeLabel: ".full",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .full,
                    timeStyle: .full
                )
                
                ExampleItem(
                    dateLabel: ".long",
                    timeLabel: ".long",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .long,
                    timeStyle: .long
                )
                
                ExampleItem(
                    dateLabel: ".medium",
                    timeLabel: ".medium",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .medium,
                    timeStyle: .medium
                )
                
                ExampleItem(
                    dateLabel: ".short",
                    timeLabel: ".short",
                    date: selectedDate,
                    locale: selectedLocale.id,
                    dateStyle: .short,
                    timeStyle: .short
                )
            }
            .padding()
        }
        .navigationTitle("Date Format using Style")
    }
}

struct DateFormat3Screen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DateFormat3Screen()
        }
    }
}

private struct ExampleItem: View {
    let dateLabel: String
    let timeLabel: String
    let date: Date
    let locale: String
    let dateStyle: DateFormatter.Style
    let timeStyle: DateFormatter.Style
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale)
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter
    }
    
    var body: some View {
        VStack {
            Text("Date: \(dateLabel) | Time: \(timeLabel)")
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
