//
//  GridTest.swift
// Arc
//
//  Created by Philip Hayes on 9/27/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
//For ui configuration only
public struct GridTest : Codable {
    
    
    public struct Size : Codable {
        var width:Int
        var height:Int
        init (width:Int, height:Int) {
            self.width = width
            self.height = height
        }
    }
    public struct Grid : Codable {
        
        public struct Symbol : Codable {
            var selected:Bool
            var symbol:Int
            var x:Int
            var y:Int
            
            init(symbol:Int, x:Int, y:Int) {
                self.symbol = symbol
                self.x = x
                self.y = y
                self.selected = false
            }
        }
        let size:Size
        var symbols:Array<Symbol>

        var values: Array<Array<Int>> = []
        init(size:Size) {
            self.size = size
            values = Array<Array<Int>>(repeating: Array<Int>(repeating: -1, count: size.width), count: size.height)
            symbols = []
        }
    }
    
    var imageGrid:Grid
    var fGrid:Grid
    
    init(imageGridSize:Size, fGridSize:Size) {
        imageGrid = Grid(size: imageGridSize)
        fGrid = Grid(size: fGridSize)
    }
    
}

//For server communication only
public struct GridTestResponse : HMTestCodable {
	public static var dataType: SurveyType = .gridTest

    public struct Section : Codable {
        public struct Choice : Codable {
            var selection_time:TimeInterval?
            var grids_selection_time:TimeInterval?
            var image_selection_time:TimeInterval?
            var x:Int
            var y:Int
            var selection:Int?
            var image:String?
            init(x:Int, y:Int, selection_time:TimeInterval?, selection:Int?) {
                self.x = x
                self.y = y
                self.selection_time = selection_time
                self.selection = selection
            }
            init(x:Int, y:Int, grid_selection_time:TimeInterval?, image_selection_time:TimeInterval?, selection:Int?) {
                self.x = x
                self.y = y
                self.grids_selection_time = grid_selection_time
                self.image_selection_time = image_selection_time
                switch selection {
                case 0:
                    self.image = "key"
                case 1:
                    self.image = "phone"
                case 2:
                    self.image = "pen"
                default:
                    self.image = nil
                }
                self.selection = selection
            }
        }
        public struct Image : Codable {
            var image:String
            var x:Int
            var y:Int
            init(x:Int, y:Int, image:String) {
                self.x = x
                self.y = y
                self.image = image
            }
        }
        
        var choices:Array<Choice>
        var display_distraction:TimeInterval?
        var display_symbols:TimeInterval?
        var display_test_grid:TimeInterval?
        var e_count:Int = 0
        var f_count:Int = 0
        var images:Array<Image>
        
        init() {
            choices = []
            images = []
        }
    }
    
    public var id: String?
    public var type: SurveyType? = .gridTest
    var sections:Array<Section>
    public var date:TimeInterval?
    
    init(id:String, numSections:Int) {
        self.id = id
        sections = Array(repeating: Section(), count: numSections)
    }
    
}

extension GridTestResponse.Section.Choice : Hashable, Comparable {
    public static func == (lhs: GridTestResponse.Section.Choice, rhs: GridTestResponse.Section.Choice) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
    public static func < (lhs: GridTestResponse.Section.Choice, rhs: GridTestResponse.Section.Choice) -> Bool {
        if let l = lhs.grids_selection_time, let r = lhs.grids_selection_time {
             return l < r
        }
        return (lhs.selection_time ?? 0) < (rhs.selection_time ?? 0)
        
    }
    
}
