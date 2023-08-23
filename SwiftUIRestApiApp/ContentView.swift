//
//  ContentView.swift
//  SwiftUIRestApiApp
//
//  Created by ipeerless on 23/08/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
            Text(user?.login ?? "login placeholder")
                .bold()
                .font(.system(size: 30))
                .font( .title)
            Text(user?.bio ?? "bio placeholder")
                .lineLimit(3)
                .font(.system(size: 22))
                .font(.subheadline)
                .padding(.top, 4)
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidUrl {
                print("invalid url")
            } catch GHError.invalidResponse {
                print("invalid response")
            } catch GHError.invalidData {
                print("invalid data")
            } catch {
                print("unexpected error")
            }
        }
    }
    func getUser() async throws -> GitHubUser {
        let endPoint = "https://api.github.com/users/twostraws"
        guard let url = URL(string: endPoint) else {throw GHError.invalidUrl}
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
    
}

enum GHError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
}
