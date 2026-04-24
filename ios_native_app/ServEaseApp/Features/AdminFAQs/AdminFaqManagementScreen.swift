import SwiftUI

struct AdminFaqManagementScreen: View {
    @StateObject private var vm = AdminFaqViewModel()

    @State private var searchText = ""

    // Category form
    @State private var categoryFormName = ""
    @State private var categoryFormSortOrder = 0
    @State private var categoryFormIsActive = true

    // FAQ form
    @State private var faqFormCategoryId = ""
    @State private var faqFormQuestion = ""
    @State private var faqFormAnswer = ""
    @State private var faqFormKeywords = ""
    @State private var faqFormSortOrder = 0
    @State private var faqFormIsActive = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(DesignTokens.slateGray)
                    TextField("Search FAQs...", text: $searchText)
                        .font(.bodyLarge)
                        .onSubmit {
                            vm.keyword = searchText
                            Task { await vm.search() }
                        }
                }
                .padding(12)
                .background(DesignTokens.pureWhite)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.inputRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.inputRadius)
                        .stroke(DesignTokens.inputBorder, lineWidth: 1)
                )

                // Action buttons
                HStack(spacing: 12) {
                    Button {
                        categoryFormName = ""
                        categoryFormSortOrder = 0
                        categoryFormIsActive = true
                        vm.showCategoryForm = true
                    } label: {
                        Label("Add category", systemImage: "plus")
                            .font(.bodyMedium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(DesignTokens.pureWhite)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(DesignTokens.inputBorder, lineWidth: 1))
                    }
                    .buttonStyle(.plain)

                    Button {
                        faqFormCategoryId = ""
                        faqFormQuestion = ""
                        faqFormAnswer = ""
                        faqFormKeywords = ""
                        faqFormSortOrder = 0
                        faqFormIsActive = true
                        vm.showFaqForm = true
                    } label: {
                        Label("Add FAQ", systemImage: "plus")
                            .font(.bodyMedium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(DesignTokens.pureWhite)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(DesignTokens.inputBorder, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                // Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.filteredCategories) { cat in
                            HStack(spacing: 4) {
                                StatusChip(cat.name, isSelected: (cat.id == "__all__" ? nil : cat.id) == vm.selectedCategoryId) {
                                    Task { await vm.filterByCategory(cat.id) }
                                }

                                if cat.id != "__all__" {
                                    Button {
                                        categoryFormName = cat.name
                                        categoryFormSortOrder = cat.sortOrder
                                        categoryFormIsActive = cat.isActive
                                        vm.editingCategory = cat
                                        vm.showCategoryForm = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .font(.caption2)
                                            .foregroundColor(DesignTokens.slateGray)
                                    }

                                    Button {
                                        Task { await vm.deactivateCategory(id: cat.id) }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }

                // Active filter
                HStack(spacing: 8) {
                    ForEach([Bool?.none, .some(true), .some(false)], id: \.self) { isActive in
                        let label: String = {
                            switch isActive {
                            case .none: return "All"
                            case .some(true): return "Active"
                            case .some(false): return "Inactive"
                            }
                        }()
                        StatusChip(label, isSelected: vm.activeFilter == isActive) {
                            Task { await vm.filterByActive(isActive) }
                        }
                    }
                }

                // FAQ list
                switch vm.status {
                case .initial:
                    EmptyView()
                case .loading:
                    ProgressView().padding(.top, 40)
                case .failure:
                    EmptyStateCard(title: "Failed to load", description: LocalizedStringKey(vm.errorMessage ?? "Error"))
                case .success:
                    if vm.items.isEmpty {
                        EmptyStateCard(title: "No FAQs", description: "Add your first FAQ entry")
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.items) { faq in
                                faqCard(faq)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(DesignTokens.cloudGray)
        .navigationTitle("FAQ management")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.loadAll() }

        // Category form sheet
        .sheet(isPresented: $vm.showCategoryForm) {
            NavigationStack {
                Form {
                    Section("Name") { TextField("Category name", text: $categoryFormName) }
                    Section("Sort order") {
                        Stepper("\(categoryFormSortOrder)", value: $categoryFormSortOrder)
                    }
                    Section { Toggle("Active", isOn: $categoryFormIsActive) }

                    Section {
                        PrimaryPillButton("Save", isLoading: vm.isMutating) {
                            Task {
                                if let editing = vm.editingCategory {
                                    await vm.updateCategory(id: editing.id, name: categoryFormName, sortOrder: categoryFormSortOrder, isActive: categoryFormIsActive)
                                } else {
                                    await vm.createCategory(name: categoryFormName, sortOrder: categoryFormSortOrder, isActive: categoryFormIsActive)
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
                .navigationTitle(vm.editingCategory != nil ? "Edit category" : "New category")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { vm.showCategoryForm = false } } }
            }
        }

        // FAQ form sheet
        .sheet(isPresented: $vm.showFaqForm) {
            NavigationStack {
                Form {
                    Section("Category") {
                        Picker("Category", selection: $faqFormCategoryId) {
                            ForEach(vm.categories) { cat in
                                Text(cat.name).tag(cat.id)
                            }
                        }
                    }
                    Section("Question") { TextField("Question", text: $faqFormQuestion) }
                    Section("Answer") { TextEditor(text: $faqFormAnswer).frame(minHeight: 100) }
                    Section("Keywords (comma-separated)") { TextField("keyword1, keyword2", text: $faqFormKeywords) }
                    Section("Sort order") { Stepper("\(faqFormSortOrder)", value: $faqFormSortOrder) }
                    Section { Toggle("Active", isOn: $faqFormIsActive) }

                    Section {
                        PrimaryPillButton("Save", isLoading: vm.isMutating) {
                            let keywords = faqFormKeywords
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }

                            Task {
                                if let editing = vm.editingFaq {
                                    await vm.updateFaq(id: editing.id, categoryId: faqFormCategoryId, question: faqFormQuestion, answer: faqFormAnswer, keywords: keywords, sortOrder: faqFormSortOrder, isActive: faqFormIsActive)
                                } else {
                                    await vm.createFaq(categoryId: faqFormCategoryId, question: faqFormQuestion, answer: faqFormAnswer, keywords: keywords, sortOrder: faqFormSortOrder, isActive: faqFormIsActive)
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
                .navigationTitle(vm.editingFaq != nil ? "Edit FAQ" : "New FAQ")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { vm.showFaqForm = false } } }
            }
        }
    }

    @ViewBuilder
    private func faqCard(_ faq: AdminFaqItem) -> some View {
        SurfaceCard(padding: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(faq.question)
                        .font(.titleLarge)
                        .foregroundColor(DesignTokens.nearBlack)
                        .lineLimit(2)
                    Spacer()
                    TagBadge(label: faq.isActive ? "Active" : "Inactive", backgroundColor: faq.isActive ? Color.green.opacity(0.12) : Color.red.opacity(0.12), textColor: faq.isActive ? .green : .red)
                }

                Text(String(faq.answer.prefix(160)) + (faq.answer.count > 160 ? "..." : ""))
                    .font(.bodyMedium)
                    .foregroundColor(DesignTokens.slateGray)
                    .lineLimit(3)

                HStack(spacing: 8) {
                    if let cat = faq.category {
                        TagBadge(label: cat.name)
                    }
                    TagBadge(label: "Sort: \(faq.sortOrder)")
                    TagBadge(label: "Views: \(faq.viewCount)")
                    Spacer()

                    Button {
                        faqFormCategoryId = faq.categoryId
                        faqFormQuestion = faq.question
                        faqFormAnswer = faq.answer
                        faqFormKeywords = faq.keywords.joined(separator: ", ")
                        faqFormSortOrder = faq.sortOrder
                        faqFormIsActive = faq.isActive
                        vm.editingFaq = faq
                        vm.showFaqForm = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(DesignTokens.slateGray)
                    }

                    Button {
                        Task { await vm.deactivateFaq(id: faq.id) }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}
