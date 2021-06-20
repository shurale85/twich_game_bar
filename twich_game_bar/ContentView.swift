//
//  ContentView.swift
//  twich_game_bar
//
//  Created by NewUSER on 20.06.2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
  
    var body: some View {
        NavigationView{
            GamesView()
        }
    }
}

struct GamesView: View {
    @StateObject var listData = getData()
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(entity: GameTable.entity(), sortDescriptors: [NSSortDescriptor(keyPath:\GameTable.name, ascending: true)]) var results : FetchedResults<GameTable>
    
    var body: some View {
        
        VStack {
            if listData.data.isEmpty {
                ProgressView()
                    .onAppear(perform: {
                        listData.fetchData(context: context)
                    })
                    
            }
            else {
                        List(0..<listData.data.count, id: \.self) { i in
                            if i == listData.data.count - 1 {
                                cellView(data: listData.data[i], isLast: true, listData:listData)
                            } else {
                                cellView(data: listData.data[i], isLast: false, listData:  listData)
                            }
                
                
                
                        }.listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("Games")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing ) {
                
                Button(action: {
                    //just to make refresh visibale
                    listData.data.removeAll()
                },
                       label:{
                        Image(systemName: "arrow.clockwise.circle").font(.title)
                       })
            }
        }

   }
    
}

struct cellView: View {
    var data: Top
    var isLast: Bool
    @ObservedObject var listData: getData
    @Environment(\.managedObjectContext) var context
    var body: some View{
        VStack(alignment: .leading, spacing: 10) {
            Text(data.game.name).fontWeight(.bold)
            Text("Channels: \(data.channels)")
            
            if isLast {
                Text("Viewers: \(data.viewers)")
                    .onAppear {
                        //need to downloed
                        print("loading data")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            listData.fetchData(context: context)
                        }
                        
                    }
            } else
            {
                Text("Viewers: \(data.viewers)")
            }
            
            
        }
    }
}

class getData: ObservableObject {
    
    @Published var data = [Top]()
    @Published var limit = 10
    
    init() {
        print("Starting")
//        fetchData()
    }
    
    func saveData(context: NSManagedObjectContext) {
        
        data.forEach{(data) in
            let entity = GameTable(context: context)
            entity.channels = Int32(Int16(data.channels))
            entity.id = Int32(data.game._id)
            entity.name = data.game.name
        }
        
        do {
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchData(context: NSManagedObjectContext) {
        
        let url = URL(string: "https://api.twitch.tv/kraken/games/top?limit=\(limit)&offset\(limit - 10)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("ahuoi1tl0qmqbyi8jo8nitbmuaad7w", forHTTPHeaderField: "Client-ID")
        request.setValue("application/vnd.twitchtv.v5+json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        
        
        session.dataTask(with: request) { (data, _, err) in
            if err != nil {
                print(err?.localizedDescription as Any)
                return
            }
            
            do {
                let json = try JSONDecoder().decode(Response.self, from: data!)
                print(json)
                let oldData = self.data
                
                DispatchQueue.main.async {
                    self.data = oldData + json.top
                    self.limit += 10
                    self.saveData(context: context)
                }
            }
            catch{
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
