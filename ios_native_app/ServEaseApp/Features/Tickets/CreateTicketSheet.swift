import SwiftUI

struct CreateTicketSheet: View {
    let onCreated: (Bool) -> Void
    @StateObject private var vm = CreateTicketViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Subject") {
                    TextField("Min 5 characters", text: $vm.subject)
                }

                Section("Category") {
                    Picker("Category", selection: $vm.category) {
                        ForEach(CreateTicketViewModel.categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                Section("Priority") {
                    Picker("Priority", selection: $vm.priority) {
                        ForEach(CreateTicketViewModel.priorities, id: \.self) { pri in
                            Text(pri).tag(pri)
                        }
                    }
                }

                Section("Description") {
                    TextEditor(text: $vm.description)
                        .frame(minHeight: 120)
                }

                if let error = vm.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.bodyMedium)
                    }
                }

                Section {
                    PrimaryPillButton("Submit ticket", isLoading: vm.status == .submitting) {
                        Task {
                            let success = await vm.submit()
                            if success {
                                onCreated(true)
                                dismiss()
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("New ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
