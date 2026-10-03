
import SwiftUI

struct HomePage: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Text("Subjects")
                        .font(.system(size: 28))
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                    
                    NavigationLink {
                        CPage()
                    } label: {
                        card(
                            image: "c",
                            name: "C Programming",
                            color: .blue
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        PythonPage()
                    } label: {
                        card(
                            image: "python",
                            name: "Python Programming",
                            color: .green
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Courses")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func card(image: String, name: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            Text(name)
                .foregroundStyle(.black)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(color.opacity(0.20))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct PythonPage: View {
    
    let chapters = [
        "Introduction to Python",
        "Python Basics",
        "Conditional Statements",
        "Loops",
        "Strings",
        "Lists",
        "Tuples and Sets",
        "Dictionaries",
        "Functions",
        "Modules and Packages",
        "File Handling",
        "Exception Handling",
        "Object-Oriented Programming",
        "Advanced Python",
        "Python Libraries",
        "Database Programming",
        "Python for Data Science",
        "Python for AI & Machine Learning",
        "Web Development with Python",
        "Python Projects"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                
                Text("Python Programming")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                ForEach(Array(chapters.enumerated()), id: \.offset) { index, chapter in
                    
                    NavigationLink {
                        ChapterPage(
                            chapterNumber: index + 1,
                            chapterName: chapter
                        )
                    } label: {
                        HStack {
                            Text("\(index + 1)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(width: 45, height: 45)
                                .background(Color.green)
                                .clipShape(Circle())
                            
                            Text(chapter)
                                .font(.headline)
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        .padding()
                        .background(Color.green.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Python")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChapterPage: View {
    
    let chapterNumber: Int
    let chapterName: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Chapter \(chapterNumber)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                
                Text(chapterName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Learn \(chapterName) with detailed explanations, examples, and practice questions.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Topics")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("• Concepts and fundamentals")
                    Text("• Examples")
                    Text("• Practical programs")
                    Text("• Practice questions")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding()
        }
        .navigationTitle("Chapter \(chapterNumber)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CPage: View {
    
    var body: some View {
        Text("C Programming")
            .font(.largeTitle)
            .fontWeight(.bold)
            .navigationTitle("C")
    }
}

#Preview {
    HomePage()
}
