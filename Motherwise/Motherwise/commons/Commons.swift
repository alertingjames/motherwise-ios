//
//  Commons.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 Motherwise. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit

//////////////// Colors //////////////////////////////////////////////////////////

var primaryDarkColor = UIColor.systemGreen
var primaryColor = UIColor.systemGreen
var lightPrimaryColor = UIColor.systemGreen

/////////////// Map /////////////////////////////////////////////////////////

var RADIUS:Float = 15.24
var baseUrl:String = "https://maps.googleapis.com/maps/api/geocode/json?"
var apikey:String = "AIzaSyA70FagAtI3h4YshXoB-nPV_p6fFnlX09k"

///////////////////////////////////////////////////////////////////////////////////

var gNote = ""
var gMapCameraMoveF:Bool = false
var gMapType:GMSMapViewType = .normal
var gHomeButton:UIButton!
var isMenuOpen:Bool = false
var gId:Int64 = 0
var gPostOpt:String = "all"
var isWeatherLocationChanged:Bool = false

var selectedRecipeType:String = "meat"

var gRecentViewController:UIViewController!

var gFCMToken:String = ""
var gBadgeCount:Int = 0
var gGroups = [Group]()
var gSelectedUsers = [User]()
var gPostPictures = [PostPicture]()
var gUsers = [User]()
var gGroupName:String = ""
var gSelectedGroupId:Int64 = 0
var gSelectedCohort:String = ""
var gMessageFilterOption:String = ""
var gConfComments = [Comment]()
var gConfUsers = [User]()
var gChatMessageCount:Int = 0
var gForecastWeatherData:ForecastData.Weathers!
var gDailyForecastWeatherData:DailyForecastData.Weathers!

var gComment1:Comment!
var gCommentsView:UIView!
var gCommentsStackView:UIStackView!

///////////// ViewController ////////////////////////////////////////////////

var gMainViewController:MainViewController!
var gHomeViewController:HomeViewController!
var gMainMenu:MainMenu!
var darkBackg:DarkBackground!
var gPostViewController:PostsViewController!
var gNewPostViewController:NewPostViewController!
var gEditPostViewController:EditPostViewController!
var gPostDetailViewController:PostDetailViewController!
var gMessageViewController:MessageViewController!
var gProfileViewController:ProfileViewController!
var gMyPostViewController:MyPostsViewController!
var gLiveVideoConfViewController:LiveVideoConfViewController!
var gYouTubeConfViewController:YouTubeConfViewController!
var gVideoFileViewController:VideoFileConfViewController!
var gGroupMembersViewController:GroupMembersViewController!
var gGroupChatViewController:GroupChatViewController!
var gPrivateChatViewController:PrivateChatViewController!
var gWeatherViewController:WeatherViewController!
var gNearbyViewController:MainVC!

var gLiveVideoConf2ViewController:LiveVideoConf2ViewController!
var gNewHomeVC:NewHomeViewController!
var gCommentVC:CommentViewController!

var gPostDetailVC:PostDetailVC!
var gComidaViewViewController:ComidaViewController!
var gFoodResourcesVC:FoodResourcesVC!




















