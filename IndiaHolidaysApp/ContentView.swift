import SwiftUI

struct Holiday: Codable, Identifiable {
    var id: String { date }
    let date: String
    let localName: String
    let name: String
    let types: [String]?
}

struct ContentView: View {
    @State private var holidays: [Holiday] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading holidays...")
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(holidays) { holiday in
                        VStack(alignment: .leading) {
                            Text(holiday.name).font(.headline)
                            Text(holiday.date).foregroundColor(.gray)
                            if let types = holiday.types {
                                Text("Type: \(types.joined(separator: ", "))")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("India Holidays 2025")
            .onAppear(perform: loadHolidays)
        }
    }

    func loadHolidays() {
        guard let url = URL(string: "https://date.nager.at/api/v3/PublicHolidays/2025/IN") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }
                do {
                    holidays = try JSONDecoder().decode([Holiday].self, from: data)
                } catch {
                    errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
