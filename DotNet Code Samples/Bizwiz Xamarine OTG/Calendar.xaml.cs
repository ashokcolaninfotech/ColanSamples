using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;
using XMobileWiz.Core;
using XMobileWiz.Core.AppInterfaces;
using XMobileWiz.Core.Services;
using XMobileWiz.W81.Model;
using XMobileWiz.W81.View.Partial;
using Windows.UI.Xaml.Shapes;
using Windows.UI.Xaml.Media.Imaging;
using Plugin.Connectivity;
using Windows.Storage;
using Windows.Storage.Streams;
using Windows.UI.Text;
using Windows.UI.Popups;
using System.Net.NetworkInformation;
using System.Threading;
using Windows.Foundation.Diagnostics;
using Windows.UI.Core;
using XMobileWiz.Core.Domain;
using XMobileWiz.Core.Domain.Builders;
using XMobileWiz.Core.Repositories;
using System.Globalization;

// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=234238

namespace XMobileWiz.W81.View
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class Calendar : Page
    {
        private ICoreApp coreApp = CoreApp.Instance;
        private List<string> daysInMonth;
        private DateTime firstDate;
        private int weekDay = 0;
        DateTime getdate = DateTime.Today;
        DateTime today = DateTime.Now;
        Popup popup1;
        Popup editnotes;
        Popup addfollowup;
        Popup addnewcustomer;
        DispatcherTimer dispatcherTimer;
        private CoreDispatcher dispatcher;
        int rowsCount = 0;
        int columncount = 0;
        public Calendar()
        {


            if (((App)(App.Current)).SyncStatus == "CustDataNotIntitalized")
            {
                this.InitializeComponent();
                btnviewline.IsTapEnabled = false;
            }
            else if (((App)(App.Current)).SyncStatus == "Ready")
            {
                this.InitializeComponent();
                if (myProgressRing.IsActive == true)
                {
                    myProgressRing.IsActive = false;
                    GridCalendarSub.Opacity = 1;
                    GridCalendarSub.IsTapEnabled = true;
                }
                dispatcher = Window.Current.Dispatcher;
                currentdatemonth.Text = today.ToString("MMMM dd, yyyy");
                selecteddate.Text = today.ToString("MMMM dd, yyyy");
                daysInMonth = new List<string>();
                GetDates(today.Year, today.Month);
                GetGridDates(today.Month, today.Day, today.Year);
                GetCalendarDetails(today.Month, today.Day, today.Year);


                //SyncCustomerData();

            }
            if ((App.Current as App).LoginStatus == false)
            {
                //alertMessagepopup.Visibility = Visibility.Visible;
                //GridCalendarSub.Opacity = 0.5;
                this.InitializeComponent();
                GridCalendarSub.IsTapEnabled = false;
                //alertMessage.Text = "Login Success";
            }


        }




        public void DispatcherTimerEvent()
        {
            dispatcherTimer = new DispatcherTimer();
            dispatcherTimer.Interval = new TimeSpan(0, 0, 50);
            //dispatcherTimer.Tick += new EventHandler<object>(Sync_Tick);
            dispatcherTimer.Start();
        }

        private async void messageBox(string msg)
        {
            var msgDlg = new Windows.UI.Popups.MessageDialog(msg.ToString());
            msgDlg.DefaultCommandIndex = 1;
            await msgDlg.ShowAsync();
        }

        private async void SyncCustomerData()
        {
            await Task.Delay(TimeSpan.FromSeconds(8));
        }

        private void GetDates(int year, int month)
        {
            var dates = new List<DateTime>();
            firstDate = new DateTime(year, month, 1);
            GetWeekDay();
            //// Loop from the first day of the month until we hit the next month, moving forward a day at a time
            for (var date = new DateTime(year, month, 1); date.Month == month; date = date.AddDays(1))
            {
                dates.Add(date);
                string dateString = date.ToString("dd");
                daysInMonth.Add(dateString);
            }
        }

        private void GetWeekDay()
        {
            switch (firstDate.DayOfWeek)
            {
                case DayOfWeek.Sunday:
                    weekDay = 0;
                    break;
                case DayOfWeek.Monday:
                    weekDay = 1;
                    break;
                case DayOfWeek.Tuesday:
                    weekDay = 2;
                    break;
                case DayOfWeek.Wednesday:
                    weekDay = 3;
                    break;
                case DayOfWeek.Thursday:
                    weekDay = 4;
                    break;
                case DayOfWeek.Friday:
                    weekDay = 5;
                    break;
                case DayOfWeek.Saturday:
                    weekDay = 6;
                    break;
            }

            for (int i = 0; i < weekDay; i++)
            {
                daysInMonth.Add(string.Empty);
            }
        }

        private void ImgPrevious_Click(object sender, RoutedEventArgs e)
        {
            myProgressRing.IsActive = true;
            today = today.AddMonths(-1);
            currentdatemonth.Text = today.ToString("MMMM dd, yyyy");
            daysInMonth = new List<string>();
            GetDates(today.Year, today.Month);
            calendarsubgrid.Children.Clear();
            GetGridDates(today.Month, today.Day, today.Year);
            GetCalendarDetails(today.Month, today.Day, today.Year);
            selecteddate.Text = today.ToString("MMMM dd, yyyy");
            gridTimeline.Visibility = Visibility.Collapsed;
            if (myProgressRing.IsActive == true)
            {
                myProgressRing.IsActive = false;
            }
        }

        private void ImgNext_Click(object sender, RoutedEventArgs e)
        {
            myProgressRing.IsActive = true;
            today = today.AddMonths(1);
            currentdatemonth.Text = today.ToString("MMMM dd, yyyy");
            daysInMonth = new List<string>();
            GetDates(today.Year, today.Month);
            calendarsubgrid.Children.Clear();
            GetGridDates(today.Month, today.Day, today.Year);
            GetCalendarDetails(today.Month, today.Day, today.Year);
            selecteddate.Text = today.ToString("MMMM dd, yyyy");
            gridTimeline.Visibility = Visibility.Collapsed;
            if (myProgressRing.IsActive == true)
            {
                myProgressRing.IsActive = false;
            }
        }

        private void CalendarSubgrid_Tapped(object sender, TappedRoutedEventArgs e)
        {
            try
            {


                DateTime dateselect = Convert.ToDateTime(currentdatemonth.Text);
                Ellipse el = new Ellipse();
                el.Fill = new SolidColorBrush(Colors.Orange);
                el.Height = 40;
                el.Width = 40;
                el.VerticalAlignment = VerticalAlignment.Top;
                var myTextBlock = sender as TextBlock;
                if (myTextBlock != null)
                {
                    var textblocks = calendarsubgrid.Children.OfType<TextBlock>().ToList();
                    var ellipse = calendarsubgrid.Children.OfType<Ellipse>().ToList();
                    foreach (var textblockitems in textblocks)
                    {
                        textblockitems.Foreground = new SolidColorBrush(Colors.Black);
                    }
                    foreach (var ellipseitems in ellipse)
                    {
                        ellipseitems.Fill = new SolidColorBrush(Colors.White);

                    }
                    int row = Grid.GetRow(myTextBlock);
                    int column = Grid.GetColumn(myTextBlock);
                    string currentdate = myTextBlock.Text;
                    int date = Convert.ToInt32(currentdate);
                    DateTime getformatteddate = Convert.ToDateTime(myTextBlock.Text + dateselect.ToString("MMMM yyyy"));
                    selecteddate.Text = getformatteddate.ToString("MMMM dd, yyyy");
                    currentdatemonth.Text = getformatteddate.ToString("MMMM dd, yyyy");
                    myTextBlock.Foreground = new SolidColorBrush(Colors.Orange);
                    GetCalendarDetails(today.Month, date, today.Year);
                    calendarsubgrid.Children.Add(el);
                    Grid.SetRow(el, row);
                    Grid.SetColumn(el, column);
                    TextBlock Box = new TextBlock();
                    Box.Tapped += new TappedEventHandler(CalendarSubgrid_Tapped);
                    Box.HorizontalAlignment = HorizontalAlignment.Center;
                    Box.VerticalAlignment = VerticalAlignment.Center;
                    Box.Foreground = new SolidColorBrush(Colors.White);
                    Box.FontFamily = new FontFamily("Helvetica Neue");
                    Box.FontWeight = FontWeights.SemiBold;
                    Box.FontSize = 18;
                    Box.Height = 20;
                    Box.Text = currentdate;
                    calendarsubgrid.Children.Add(Box);
                    Grid.SetRow(Box, row);
                    Grid.SetColumn(Box, column);

                }
            }
            catch (Exception ex)
            {

            }
        }

        private void ImgCalendar_Tapped(object sender, TappedRoutedEventArgs e)
        {


            popup1 = new Popup();
            // this.Background = new SolidColorBrush(Colors.Gray);
            PopupNavigationDrawer pnd = new PopupNavigationDrawer();
            GridCalendar.Opacity = 0.4;
            GridCalendar.Background = new SolidColorBrush(Colors.Black);
            popup1.Child = pnd;
            popup1.IsOpen = true;
            popup1.Height = 1000;
            popup1.Width = 450;
            popup1.HorizontalAlignment = HorizontalAlignment.Left;
            popup1.Closed += (s1, e1) =>
            {

            };
        }

        private void Grid_Tapped(object sender, TappedRoutedEventArgs e)
        {
            if ((App.Current as App).mainPopup != null)
            {
                if ((App.Current as App).mainPopup.IsOpen)
                {
                    (App.Current as App).mainPopup.IsOpen = false;
                    var currentPage = Window.Current.Content as Page;
                    currentPage.Opacity = 1;
                    //GridCalendar.Opacity = 1;
                    //GridCalendar.Background = new SolidColorBrush(Colors.Transparent);

                }
            }
            if ((App.Current as App).customersearchpopup != null)
            {
                if ((App.Current as App).customersearchpopup.IsOpen)
                {
                    (App.Current as App).customersearchpopup.IsOpen = false;
                    var currentPage = Window.Current.Content as Page;
                    currentPage.Opacity = 1;
                    //GridCalendar.Opacity = 1;
                    //GridCalendar.Background = new SolidColorBrush(Colors.Transparent);

                }
            }

        }

        public void GetGridDates(int Month, int Day, int Year)
        {
            int dayindex = 0;
            IServiceFactory factory = coreApp.GetServiceFactory();
            IUserService userService = factory.GetUserService();
            var settings = userService.GetUserSettings();
            var calendarData = userService.GetCalendarData();
            var julyEvents = calendarData.GetEvents(Year, Month).ToList();
            int AppointmentCount = 0;



            for (int row = 1; row <= 24; row = row + 4)
            {
                for (int column = 0; column < 7; column++)
                {
                    Ellipse el = new Ellipse();
                    el.Fill = new SolidColorBrush(Colors.Orange);
                    el.Height = 40;
                    el.Width = 40;
                    el.VerticalAlignment = VerticalAlignment.Top;

                    TextBlock Box = new TextBlock();
                    Box.Tapped += new TappedEventHandler(CalendarSubgrid_Tapped);
                    Box.HorizontalAlignment = HorizontalAlignment.Center;
                    Box.VerticalAlignment = VerticalAlignment.Center;
                    Box.Foreground = new SolidColorBrush(Colors.Black);
                    Box.FontFamily = new FontFamily("Helvetica Neue");
                    Box.FontWeight = FontWeights.SemiBold;
                    Box.FontSize = 18;

                    // Box.FontSize = 20;
                    if (daysInMonth.Count > dayindex)
                    {
                        Box.Text = daysInMonth[dayindex];

                        foreach (var items in julyEvents)
                        {
                            DateTime dates;

                            string[] formats = { "MMMM dd, yyyy", "M/dd/yyyy", "MM/dd/yyyy", "M/d/yyyy", "dd/MM/yyyy" };
                            if (DateTime.TryParseExact(items.FormattedApptDate, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out dates))
                            {

                                DateTime date = Convert.ToDateTime(items.FormattedApptDate);
                                int linecount = 0;
                                linecount = row + 1;
                                AppointmentCount = 0;
                                if (date.Date.ToString("dd") == Box.Text)
                                {
                                    AppointmentCount =
                                       julyEvents.Where(n => n.FormattedApptDate == items.FormattedApptDate).Count();
                                    for (int indicate = 0; indicate < AppointmentCount; indicate++)
                                    {
                                        if (indicate < 3)
                                        {
                                            Line line = new Line();
                                            line.Stroke = new SolidColorBrush(Colors.Orange);
                                            line.StrokeThickness = 5;
                                            line.X1 = 10;
                                            line.X2 = 1;
                                            line.Stretch = Stretch.Fill;
                                            line.Width = 50;
                                            line.HorizontalAlignment = HorizontalAlignment.Center;
                                            calendarsubgrid.Children.Add(line);
                                            Grid.SetRow(line, linecount);
                                            Grid.SetColumn(line, column);
                                            linecount += 1;
                                        }

                                    }


                                }
                            }


                        }
                        var CurrentDay = DateTime.Now.ToString("dd");
                        int CurrentMonth = DateTime.Now.Month;
                        int CurrentYear = DateTime.Now.Year;

                        if (Box.Text == CurrentDay && Month == CurrentMonth && Year == CurrentYear)
                        {
                            calendarsubgrid.Children.Add(el);
                            Grid.SetRow(el, row);
                            Grid.SetColumn(el, column);
                            Box.Foreground = new SolidColorBrush(Colors.White);
                        }
                        calendarsubgrid.Children.Add(Box);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);

                    }
                    dayindex++;

                }

            }
        }

        public void GetCalendarDetails(int Month, int Day, int Year)
        {
            //getcalendardetails
            IServiceFactory factory = coreApp.GetServiceFactory();
            IUserService userService = factory.GetUserService();
            var settings = userService.GetUserSettings();
            var calendarData = userService.GetCalendarData();
            var julyEvents = calendarData.GetEvents(Year, Month).ToList();
            var todaysEvents = calendarData.GetEvents(Year, Month, Day);

            foreach (var _eventField in todaysEvents)
            {
                if (_eventField.EventType.ToLower() == "notes")
                {
                    _eventField.EventType = "CALENDAR -" + " " + _eventField.EventType;

                }

            }

            CalendarDetail.ItemsSource = todaysEvents;

            txtcustomerfullname.Text = settings.EmployeeFullName;
            (App.Current as App).CustomerUserName = txtcustomerfullname.Text;

            //enable and disable modules
            //CalendarModule();
            int columncount = 0;
            int rowscount = 1;

            settings.AppModules.Insert(1, new AppModule { DisplayStatus = "Enabled", ModuleName = "Calendar" });
            settings.AppModules.Insert(2, new AppModule { DisplayStatus = "Enabled", ModuleName = "Messages" });
            settings.AppModules.Insert(3, new AppModule { DisplayStatus = "Enabled", ModuleName = "FollowUp" });
            settings.AppModules.Insert(0, new AppModule { DisplayStatus = "Enabled", ModuleName = "AddCustomer" });
            settings.AppModules.Insert(3, new AppModule { DisplayStatus = "Enabled", ModuleName = "MyCustomer" });
            var distinctItems = (settings.AppModules.GroupBy(x => x.ModuleName).Select(y => y.First())).ToList();




            dynamicImagelogo.RowDefinitions.Clear();
            dynamicImagelogo.ColumnDefinitions.Clear();

            dynamicImagelogo.Children.Clear();

            dynamicImagelogo.ColumnDefinitions.Add(new ColumnDefinition());
            dynamicImagelogo.ColumnDefinitions.Add(new ColumnDefinition());

            dynamicImagelogo.RowDefinitions.Add(new RowDefinition() { Height = new GridLength(20) });
            dynamicImagelogo.RowDefinitions.Add(new RowDefinition());
            dynamicImagelogo.RowDefinitions.Add(new RowDefinition());
            dynamicImagelogo.RowDefinitions.Add(new RowDefinition() { Height = new GridLength(40) });
            dynamicImagelogo.RowDefinitions.Add(new RowDefinition());
            dynamicImagelogo.RowDefinitions.Add(new RowDefinition());
            dynamicImagelogo.RowDefinitions.Add(new RowDefinition() { Height = new GridLength(40) });
            dynamicImagelogo.RowDefinitions.Add(new RowDefinition());
            dynamicImagelogo.RowDefinitions.Add(new RowDefinition());
            dynamicImagelogo.RowDefinitions.Add(new RowDefinition() { Height = new GridLength(40) });






            for (int indicate = 0; indicate < distinctItems.Count(); indicate++)
            {
                if (columncount < 2)
                {
                    if (distinctItems[indicate].DisplayStatus != "Hidden")
                    {

                        string modulename = distinctItems[indicate].ModuleName;
                        string displaystatus = distinctItems[indicate].DisplayStatus;
                        Load_Images(modulename, displaystatus, rowscount, columncount);
                        columncount++;
                        if (columncount == 2)
                        {
                            rowscount = rowscount + 3;
                            columncount = 0;
                        }
                    }
                }


            }

        }


        //private async void LoadDisabled_Images(string modulename)
        //{
        //    StorageFile file;
        //    switch (modulename)
        //    {
        //        case "AddCustomer":
        //            file =
        //                await
        //                    StorageFile.GetFileFromApplicationUriAsync(
        //                        new Uri("ms-appx:///Resources/ic_disable_addcustomer.png"));
        //            using (IRandomAccessStream fileStream = await file.OpenAsync(Windows.Storage.FileAccessMode.Read))
        //            {
        //                BitmapImage image = new BitmapImage();
        //                image.SetSource(fileStream);
        //                //  imgmenucalendarclick.Source = image;
        //            }
        //            break;
        //        case "Followups":
        //            file =
        //                await
        //                    StorageFile.GetFileFromApplicationUriAsync(
        //                        new Uri("ms-appx:///Resources/img_disabled_followups.png"));
        //            using (IRandomAccessStream fileStream = await file.OpenAsync(Windows.Storage.FileAccessMode.Read))
        //            {
        //                BitmapImage image = new BitmapImage();
        //                image.SetSource(fileStream);
        //                //  img2.Source = image;
        //            }
        //            break;
        //        case "Messages":
        //            file =
        //                await
        //                    StorageFile.GetFileFromApplicationUriAsync(
        //                        new Uri("ms-appx:///Resources/img_disabled_messages.png"));
        //            using (IRandomAccessStream fileStream = await file.OpenAsync(Windows.Storage.FileAccessMode.Read))
        //            {
        //                BitmapImage image = new BitmapImage();
        //                image.SetSource(fileStream);
        //                // imgaddcustomer.Source = image;
        //            }
        //            break;
        //        case "MyCustomers":
        //            file =
        //                await
        //                    StorageFile.GetFileFromApplicationUriAsync(
        //                        new Uri("ms-appx:///Resources/img_disabled_mycustomer.png"));
        //            using (IRandomAccessStream fileStream = await file.OpenAsync(Windows.Storage.FileAccessMode.Read))
        //            {
        //                BitmapImage image = new BitmapImage();
        //                image.SetSource(fileStream);
        //                //   imgaddcustomer.Source = image;
        //            }
        //            break;
        //        case "TimeClock":
        //            file =
        //                await
        //                    StorageFile.GetFileFromApplicationUriAsync(
        //                        new Uri("ms-appx:///Resources/img_disabled_timeclock.png"));
        //            using (IRandomAccessStream fileStream = await file.OpenAsync(Windows.Storage.FileAccessMode.Read))
        //            {
        //                BitmapImage image = new BitmapImage();
        //                image.SetSource(fileStream);
        //                //  imgaddcustomer.Source = image;
        //            }
        //            break;
        //    }

        //}

        private void Load_Images(string modulename, string displaystatus, int row, int column)
        {
            string upperModuleName = modulename.ToUpper();
            switch (modulename)
            {

                case "TimeClock":
                    if (displaystatus != "Disabled")
                    {
                        Image Box = new Image();
                        Image Boxdisable = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_timeclock.png", UriKind.RelativeOrAbsolute));
                        Boxdisable.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_timeclock_click.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        Boxdisable.Height = 100;
                        Boxdisable.Width = 100;
                        Box.Name = "timeclock_enabled";
                        Boxdisable.Name = "timeclock_selected";
                        T1.Text = upperModuleName;
                        T1.Foreground = new SolidColorBrush(Colors.Gray);
                        T1.Name = "timeclock";

                        // T1.Tapped += new TappedEventHandler(Text_Tapped);
                        Box.Tapped += new TappedEventHandler(Image_Tapped);
                        // Boxdisable.Tapped += new TappedEventHandler(DisableImage_Tapped);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(Boxdisable);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        Grid.SetRow(Boxdisable, row);
                        Grid.SetColumn(Boxdisable, column);
                        Boxdisable.Visibility = Visibility.Collapsed;
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);


                    }
                    else if (displaystatus == "Disabled")
                    {

                        Image Box = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/img_disabled_timeclock.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        Box.Name = "default_disabled";
                        T1.Text = upperModuleName;
                        T1.Name = "timeclockdisabled";
                        T1.Foreground = new SolidColorBrush(Colors.Gray);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.FontFamily = new FontFamily("Open sans");
                        //T1.Margin = new Thickness(0, 70, 20, 0);
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }



                    break;

                case "AddCustomer":
                    if (displaystatus != "Disabled")
                    {
                        Image Box = new Image();
                        Image Boxdisable = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_addcustomer.png", UriKind.RelativeOrAbsolute));
                        // Boxdisable.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_addcustomer_click.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        // Boxdisable.Height = 100;
                        // Boxdisable.Width = 100;
                        Box.Name = "addcustomer_enabled";
                        //  Boxdisable.FirstName = "addcustomer_selected";
                        T1.Text = upperModuleName;

                        T1.Foreground = new SolidColorBrush(Colors.Gray);
                        T1.Name = "addcustomer";
                        // T1.Tapped += new TappedEventHandler(Text_Tapped);
                        Box.Tapped += new TappedEventHandler(Image_Tapped);
                        // Boxdisable.Tapped += new TappedEventHandler(DisableImage_Tapped);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        dynamicImagelogo.Children.Add(Box);
                        // dynamicImagelogo.Children.Add(Boxdisable);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        // Grid.SetRow(Boxdisable, row);
                        //Grid.SetColumn(Boxdisable, column);
                        // Boxdisable.Visibility = Visibility.Collapsed;
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }
                    else if (displaystatus == "Disabled")
                    {

                        Image Box = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_disable_addcustomer.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        T1.Text = upperModuleName;
                        Box.Name = "default_disabled";

                        //  Box.Tapped += new TappedEventHandler(Image_Tapped);
                        T1.Foreground = new SolidColorBrush(Colors.Gray);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.Name = "addcustomerdisabled";
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        //T1.Margin = new Thickness(0, 70, 20, 0);
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }



                    break;

                case "Calendar":
                    if (displaystatus != "Disabled")
                    {
                        Image Box = new Image();
                        Image Boxdisable = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_calender_click.png", UriKind.RelativeOrAbsolute));
                        Boxdisable.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_calender.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        Boxdisable.Height = 100;
                        Boxdisable.Width = 100;
                        Box.Name = "calendar_selected";
                        Boxdisable.Name = "calendar_enabled";
                        // Box.Tapped += new TappedEventHandler(DisableImage_Tapped);
                        Boxdisable.Tapped += new TappedEventHandler(Image_Tapped);
                        T1.Text = upperModuleName;
                        T1.Foreground = new SolidColorBrush(Colors.Black);
                        // T1.Tapped += new TappedEventHandler(Text_Tapped);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.Name = "calendar";
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(Boxdisable);
                        dynamicImagelogo.Children.Add(T1);

                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        Grid.SetRow(Boxdisable, row);
                        Grid.SetColumn(Boxdisable, column);
                        Boxdisable.Visibility = Visibility.Collapsed;
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }
                    else if (displaystatus == "Disabled")
                    {

                        Image Box = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/img_disabled_calendar.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        Box.Name = "default_disabled";
                        T1.Text = upperModuleName;
                        T1.Foreground = new SolidColorBrush(Colors.Black);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.Name = "calendardisabled";
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        //T1.Margin = new Thickness(0, 70, 20, 0);
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }



                    break;

                case "FollowUp":

                    if (displaystatus != "Disabled")
                    {
                        Image Box = new Image();
                        Image Boxdisable = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_followup.png", UriKind.RelativeOrAbsolute));
                        Boxdisable.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_followup_click.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        Boxdisable.Height = 100;
                        Boxdisable.Width = 100;
                        Box.Name = "followup_enabled";
                        Boxdisable.Name = "followup_selected";
                        T1.Text = upperModuleName;
                        T1.Foreground = new SolidColorBrush(Colors.Gray);
                        Box.Tapped += new TappedEventHandler(Image_Tapped);
                        //T1.Margin = new Thickness(0, 70, 50, 0);
                        //  T1.Tapped += new TappedEventHandler(Text_Tapped);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.Name = "followup";
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(Boxdisable);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        Grid.SetRow(Boxdisable, row);
                        Grid.SetColumn(Boxdisable, column);
                        Boxdisable.Visibility = Visibility.Collapsed;
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }
                    else if (displaystatus == "Disabled")
                    {

                        Image Box = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/img_disabled_followups.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        Box.Name = "default_disabled";
                        T1.Text = upperModuleName;
                        T1.Foreground = new SolidColorBrush(Colors.Gray);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.Name = "followupsdisabled";
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        //T1.Margin = new Thickness(0, 70, 20, 0);
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }
                    break;


                case "Messages":
                    if (displaystatus != "Disabled")
                    {
                        Image Box = new Image();
                        Image Boxdisable = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_message.png", UriKind.RelativeOrAbsolute));
                        Boxdisable.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_message_click.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        Boxdisable.Height = 100;
                        Boxdisable.Width = 100;
                        Box.Name = "messages_enabled";
                        Boxdisable.Name = "messages_selected";
                        Box.Tapped += new TappedEventHandler(Image_Tapped);
                        // Boxdisable.Tapped += new TappedEventHandler(DisableImage_Tapped);
                        T1.Text = upperModuleName;
                        T1.Foreground = new SolidColorBrush(Colors.Gray);
                        // T1.Tapped += new TappedEventHandler(Text_Tapped);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.Name = "messages";
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(Boxdisable);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        Grid.SetRow(Boxdisable, row);
                        Grid.SetColumn(Boxdisable, column);
                        Boxdisable.Visibility = Visibility.Collapsed;
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }
                    else if (displaystatus == "Disabled")
                    {

                        Image Box = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/img_disabled_messages.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        Box.Name = "default_disabled";
                        T1.Text = upperModuleName;
                        T1.Foreground = new SolidColorBrush(Colors.Gray);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.Name = "messagesdisabled";
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        //T1.Margin = new Thickness(0, 70, 20, 0);
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }
                    break;

                case "MyCustomer":
                    if (displaystatus != "Disabled")
                    {
                        Image Box = new Image();
                        Image Boxdisable = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_mycustomer.png", UriKind.RelativeOrAbsolute));
                        Boxdisable.Source = new BitmapImage(new Uri("ms-appx:///Resources/ic_menu_mycustomer_click.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;
                        Box.Width = 100;
                        Boxdisable.Height = 100;
                        Boxdisable.Width = 100;
                        Box.Name = "mycustomer_enabled";
                        Boxdisable.Name = "mycustomer_selected";
                        Box.Tapped += new TappedEventHandler(Image_Tapped);
                        T1.Text = upperModuleName;
                        T1.Foreground = new SolidColorBrush(Colors.Gray);
                        //T1.Margin = new Thickness(0, 70, 50, 0);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.Name = "mycustomers";
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        //T1.Tapped += new TappedEventHandler(Image_Tapped);
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(Boxdisable);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        Grid.SetRow(Boxdisable, row);
                        Grid.SetColumn(Boxdisable, column);
                        Boxdisable.Visibility = Visibility.Collapsed;
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }
                    else if (displaystatus == "Disabled")
                    {

                        Image Box = new Image();
                        TextBlock T1 = new TextBlock();
                        Box.Source = new BitmapImage(new Uri("ms-appx:///Resources/img_disabled_mycustomer.png", UriKind.RelativeOrAbsolute));
                        Box.Height = 100;

                        Box.Width = 100;
                        Box.Name = "default_disabled";
                        T1.Text = upperModuleName;
                        T1.Foreground = new SolidColorBrush(Colors.Gray);
                        T1.FontSize = 21;
                        T1.FontWeight = FontWeights.Bold;
                        T1.FontFamily = new FontFamily("Open sans");
                        T1.HorizontalAlignment = HorizontalAlignment.Center;
                        T1.VerticalAlignment = VerticalAlignment.Center;
                        T1.Name = "mycustomerdisabled";
                        //T1.Margin = new Thickness(0, 70, 20, 0);
                        dynamicImagelogo.Children.Add(Box);
                        dynamicImagelogo.Children.Add(T1);
                        Grid.SetRow(Box, row);
                        Grid.SetColumn(Box, column);
                        row++;
                        Grid.SetRow(T1, row);
                        Grid.SetColumn(T1, column);

                    }
                    break;

            }

        }

        //private void Text_Tapped(object sender, TappedRoutedEventArgs e)
        //{
        //    var dynamicTextblocks = dynamicImagelogo.Children.OfType<TextBlock>().ToList();
        //    foreach (var objdynamic in dynamicTextblocks)
        //    {
        //        objdynamic.Foreground = new SolidColorBrush(Colors.Gray);

        //    }
        //    var objtextblock = sender as TextBlock;
        //    objtextblock.Foreground = new SolidColorBrush(Colors.Black);



        //    string selected = objtextblock.FirstName;
        //    var selectedsplit = selected.Split('_');
        //    string split1 = selectedsplit[0];


        //    var dynamicImage = dynamicImagelogo.Children.OfType<Image>().ToList();

        //    foreach (var obj in dynamicImage)
        //    {


        //        if (obj.FirstName == "default_disabled")
        //        {
        //            obj.Visibility = Visibility.Visible;
        //        }
        //        else if (obj.FirstName.Contains(split1) && obj.FirstName.Contains("selected"))
        //        {
        //            obj.Visibility = Visibility.Visible;
        //        }
        //        else
        //        {
        //            obj.Visibility = Visibility.Collapsed;
        //        }
        //    }


        //    if ((objtextblock.Text).ToLower() == "timeclock")
        //    {
        //        CalendarView.Visibility = Visibility.Collapsed;
        //        TimelineView.Visibility = Visibility.Collapsed;
        //        TimeClockView.Visibility = Visibility.Visible;
        //        Messages.Visibility = Visibility.Collapsed;

        //    }
        //    else if ((objtextblock.Text).ToLower() == "calendar")
        //    {
        //        CalendarView.Visibility = Visibility.Visible;
        //        TimelineView.Visibility = Visibility.Collapsed;
        //        TimeClockView.Visibility = Visibility.Collapsed;
        //        Messages.Visibility = Visibility.Collapsed;
        //    }
        //    else if ((objtextblock.Text).ToLower() == "messages")
        //    {
        //        CalendarView.Visibility = Visibility.Collapsed;
        //        TimelineView.Visibility = Visibility.Collapsed;
        //       TimeClockView.Visibility = Visibility.Collapsed;
        //        Messages.Visibility = Visibility.Visible;
        //    }


        //}
        private void Image_Tapped(object sender, TappedRoutedEventArgs e)
        {
            var dynamicImage = dynamicImagelogo.Children.OfType<Image>().ToList();

            var objimgblock = sender as Image;
            string selected = objimgblock.Name;

            var selectedsplit = selected.Split('_');
            string split1 = selectedsplit[0];

            var dynamicTextblocks = dynamicImagelogo.Children.OfType<TextBlock>().ToList();
            foreach (var objdynamic in dynamicTextblocks)
            {
                if (objdynamic.Name.Contains(split1))
                {
                    objdynamic.Foreground = new SolidColorBrush(Colors.Black);
                }
                else
                {
                    objdynamic.Foreground = new SolidColorBrush(Colors.Gray);
                }

            }

            foreach (var obj in dynamicImage)
            {
                if (obj.Name == "default_disabled")
                {
                    obj.Visibility = Visibility.Visible;
                }
                else if (!obj.Name.Contains(split1) && obj.Name.Contains("selected"))
                {
                    obj.Visibility = Visibility.Collapsed;
                }
                else if (obj.Name == "calendar_enabled" && obj.Name.Contains(split1))
                {
                    obj.Visibility = Visibility.Collapsed;
                }
                else
                {
                    obj.Visibility = Visibility.Visible;
                }


            }

            if ((selected).Contains("timeclock"))
            {
                CalendarView.Visibility = Visibility.Collapsed;
                TimelineView.Visibility = Visibility.Collapsed;
                TimeClockView.Visibility = Visibility.Visible;
                MyCustomer.Visibility = Visibility.Collapsed;
                Messages.Visibility = Visibility.Collapsed;
                ListFollowUp.Visibility = Visibility.Collapsed;
            }
            else if ((selected).Contains("calendar"))
            {
                CalendarView.Visibility = Visibility.Visible;
                TimelineView.Visibility = Visibility.Collapsed;
                TimeClockView.Visibility = Visibility.Collapsed;
                Messages.Visibility = Visibility.Collapsed;
                ListFollowUp.Visibility = Visibility.Collapsed;
                MyCustomer.Visibility = Visibility.Collapsed;
            }
            else if ((selected).Contains("messages"))
            {
                CalendarView.Visibility = Visibility.Collapsed;
                TimelineView.Visibility = Visibility.Collapsed;
                TimeClockView.Visibility = Visibility.Collapsed;
                Messages.Visibility = Visibility.Visible;
                ListFollowUp.Visibility = Visibility.Collapsed;
                MyCustomer.Visibility = Visibility.Collapsed;
            }
            else if ((selected).Contains("followup"))
            {
                CalendarView.Visibility = Visibility.Collapsed;
                TimelineView.Visibility = Visibility.Collapsed;
                TimeClockView.Visibility = Visibility.Collapsed;
                Messages.Visibility = Visibility.Collapsed;
                ListFollowUp.Visibility = Visibility.Visible;
                MyCustomer.Visibility = Visibility.Collapsed;

            }
            else if ((selected).Contains("addcustomer"))
            {
                string fstname = "";
                string lstname = "";
                string address = "";
                string city = "";
                addnewcustomer = new Popup();
                string status = "ADD NEW CUSTOMER";
                (App.Current as App).CustomerStatus = status;
                AddNewCustomer en = new AddNewCustomer(status, fstname, lstname, address, city);
                //var currentPage = Window.Current.Content as Page;
                //currentPage.Opacity = 0.4;
                //   currentPage.IsEnabled = false;

                var rootFrame = new MasterPage();
                rootFrame.Opacity = 0.4;
                rootFrame.Tapped += new TappedEventHandler(EditNotePopupClose_Tapped);
                rootFrame.ContentFrame.Navigate(typeof(Calendar));
                Window.Current.Content = rootFrame;
                Window.Current.Activate();
                addnewcustomer.Child = en;
                addnewcustomer.HorizontalOffset = Window.Current.Bounds.Width - 1650;
                addnewcustomer.VerticalOffset = Window.Current.Bounds.Height - 1000;
                addnewcustomer.IsOpen = true;
                addnewcustomer.Height = 1000;
                addnewcustomer.Width = 700;
                addnewcustomer.HorizontalAlignment = HorizontalAlignment.Center;
                addnewcustomer.VerticalAlignment = VerticalAlignment.Center;
                addnewcustomer.Margin = new Thickness(400, 200, 0, 0);
            }
            else if ((selected).Contains("mycustomer"))
            {
                CalendarView.Visibility = Visibility.Collapsed;
                TimelineView.Visibility = Visibility.Collapsed;
                TimeClockView.Visibility = Visibility.Collapsed;
                Messages.Visibility = Visibility.Collapsed;
                MyCustomer.Visibility = Visibility.Visible;
                ListFollowUp.Visibility = Visibility.Collapsed;

            }

        }
        //      private void DisableImage_Tapped(object sender, TappedRoutedEventArgs e)
        //{
        //    var dynamicImage = dynamicImagelogo.Children.OfType<Image>().ToList();

        //    var objimgblock = sender as Image;
        //    string selected = objimgblock.FirstName;

        //    var selectedsplit = selected.Split('_');
        //    string split1 = selectedsplit[0];

        //    var dynamicTextblocks = dynamicImagelogo.Children.OfType<TextBlock>().ToList();
        //    foreach (var objdynamic in dynamicTextblocks)
        //    {
        //        if (objdynamic.FirstName.Contains(split1))
        //        {
        //            objdynamic.Foreground = new SolidColorBrush(Colors.Black);
        //        }
        //        else
        //        {
        //            objdynamic.Foreground = new SolidColorBrush(Colors.Gray);
        //        }

        //    }


        //    foreach (var obj in dynamicImage)
        //   {


        //     if (obj.FirstName == "default_disabled")
        //        {
        //            obj.Visibility = Visibility.Visible;
        //        }
        //        else if (!obj.FirstName.Contains(split1) && obj.FirstName.Contains("selected"))
        //        {
        //            obj.Visibility = Visibility.Collapsed;
        //        }
        //        else
        //        {
        //            obj.Visibility = Visibility.Visible;
        //        }
        //    }

        //    if ((selected).Contains("timeclock"))
        //    {
        //        CalendarView.Visibility = Visibility.Collapsed;
        //        TimelineView.Visibility = Visibility.Collapsed;
        //        TimeClockView.Visibility = Visibility.Visible;
        //        Messages.Visibility = Visibility.Collapsed;
        //    }
        //    else if ((selected).Contains("calendar"))
        //    {
        //        CalendarView.Visibility = Visibility.Visible;
        //        TimelineView.Visibility = Visibility.Collapsed;
        //        TimeClockView.Visibility = Visibility.Collapsed;
        //        Messages.Visibility = Visibility.Collapsed;
        //    }
        //    else if ((selected).Contains("messages"))
        //    {
        //        CalendarView.Visibility = Visibility.Collapsed;
        //        TimelineView.Visibility = Visibility.Collapsed;
        //        TimeClockView.Visibility = Visibility.Collapsed;
        //        Messages.Visibility = Visibility.Visible;
        //    }

        //}

        private void AppointmentsListbox_Tapped(object sender, TappedRoutedEventArgs e)
        {
            try
            {
                if (((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem).EventType == "CALENDAR - NOTES")
                {
                    btnviewline.Content = "EDIT NOTE";
                    // EventType.Text = ((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem).EventType;
                    notesName.Text = "CALENDAR - NOTES :" + " " + ((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem).EventNotes;
                }
                else
                {
                    btnviewline.Content = "VIEW TIMELINE";
                }

                //set background as default
                foreach (var item in CalendarDetail.Items)
                {
                    try
                    {
                        ListBoxItem objItem = this.CalendarDetail.ItemContainerGenerator.ContainerFromItem(item) as ListBoxItem;
                        StackPanel objstack = FindFirstElementInVisualTree<StackPanel>(objItem);

                        objstack.Background = new SolidColorBrush(Colors.AliceBlue);
                        ((objstack).FindName("EventType") as TextBlock).Foreground =
                            App.Current.Resources["myBrush"] as SolidColorBrush;
                        ((objstack).FindName("customerfullname") as TextBlock).Foreground =
                            App.Current.Resources["myBrush"] as SolidColorBrush;
                        ((objstack).FindName("CustomerAddress") as TextBlock).Foreground =
                            App.Current.Resources["myBrush"] as SolidColorBrush;
                        ((objstack).FindName("ApptTime") as TextBlock).Foreground =
                            App.Current.Resources["myBrush"] as SolidColorBrush;
                        ((objstack).FindName("EventNotes") as TextBlock).Foreground =
                            App.Current.Resources["myBrush"] as SolidColorBrush;
                        //  ((objstack).FindName("CustomerAddress") as TextBlock).Visibility = Visibility.Collapsed;
                        //     ((objstack).FindName("staticcalendar") as TextBlock).Foreground =
                        //    App.Current.Resources["myBrush"] as SolidColorBrush;
                    }
                    catch (Exception ex)
                    {

                    }



                }

                //set background for selected events
                StackPanel objstackpanel = sender as StackPanel;

                objstackpanel.Background = App.Current.Resources["myBrush"] as SolidColorBrush;
                ((sender as StackPanel).FindName("EventType") as TextBlock).Foreground =
                    new SolidColorBrush(Colors.White);
                ((sender as StackPanel).FindName("customerfullname") as TextBlock).Foreground =
                    new SolidColorBrush(Colors.White);
                ((sender as StackPanel).FindName("CustomerAddress") as TextBlock).Foreground =
                    new SolidColorBrush(Colors.White);
                ((sender as StackPanel).FindName("ApptTime") as TextBlock).Foreground = new SolidColorBrush(Colors.White);
                ((sender as StackPanel).FindName("EventNotes") as TextBlock).Foreground = new SolidColorBrush(Colors.White);
                //((sender as StackPanel).FindName("staticcalendar") as TextBlock).Foreground = new SolidColorBrush(Colors.White);
                gridTimeline.Visibility = Visibility.Visible;
                cutomername.Text = ((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem).CustomerFullName;
            }
            catch (Exception ex)
            {

            }


        }


        //get my child inside listbox
        private T FindFirstElementInVisualTree<T>(DependencyObject parentElement) where T : DependencyObject
        {
            var count = VisualTreeHelper.GetChildrenCount(parentElement);
            if (count == 0)
                return null;

            for (int i = 0; i < count; i++)
            {
                var child = VisualTreeHelper.GetChild(parentElement, i);

                if (child != null && child is T)
                {
                    return (T)child;
                }
                else
                {
                    var result = FindFirstElementInVisualTree<T>(child);
                    if (result != null)
                        return result;

                }
            }
            return null;
        }

        //close for timeline in calendar
        private void CloseTimeLine_Tapped(object sender, TappedRoutedEventArgs e)
        {
            gridTimeline.Visibility = Visibility.Collapsed;
            notesName.Text = String.Empty;
            //EventType.Text = String.Empty;
            cutomername.Text = String.Empty;
        }

        //calendar icon for enable module
        //private void CalendarIcon_Tapped(object sender, TappedRoutedEventArgs e)
        //{
        //    CalendarModule();
        //}

        //// public void CalendarModule()
        // {
        //     // stackcalendar.IsTapEnabled = true;
        //     //stacktimeclock.IsTapEnabled = false;
        //     //stackmessages.IsTapEnabled = false;
        //     //stackaddcustomer.IsHitTestVisible = false;
        //     //stackaddfollowup.IsTapEnabled = false;
        //     //stackmycusomters.IsTapEnabled = false;
        //     txtCalendar.Foreground = new SolidColorBrush(Colors.Black);
        //     txtTimeClock.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtMessages.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtAddCustomer.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtAddFollowUps.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtMyCustomer.Foreground = new SolidColorBrush(Colors.Gray);
        // }

        // //Timeclock icon for enable module
        // private void TimeclockIcon_Tapped(object sender, TappedRoutedEventArgs e)
        // {
        //     stacktimeclock.IsHitTestVisible = true;
        //     //stackcalendar.IsHitTestVisible = false;
        //     //stackmessages.IsHitTestVisible = false;
        //     //stackaddcustomer.IsHitTestVisible = false;
        //     //stackaddfollowup.IsHitTestVisible = false;
        //     //stackmycusomters.IsHitTestVisible = false;
        //     txtTimeClock.Foreground = new SolidColorBrush(Colors.Black);
        //     txtCalendar.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtMessages.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtAddCustomer.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtAddFollowUps.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtMyCustomer.Foreground = new SolidColorBrush(Colors.Gray);
        // }

        // //Messages icon for enable module
        // private void MessagesIcon_Tapped(object sender, TappedRoutedEventArgs e)
        // {
        //     stackmessages.IsHitTestVisible = true;
        //     //stacktimeclock.IsHitTestVisible = false;
        //     //stackcalendar.IsHitTestVisible = false;
        //     //stackaddcustomer.IsHitTestVisible = false;
        //     //stackaddfollowup.IsHitTestVisible = false;
        //     //stackmycusomters.IsHitTestVisible = false;
        //     txtMessages.Foreground = new SolidColorBrush(Colors.Black);
        //     txtTimeClock.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtCalendar.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtAddCustomer.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtAddFollowUps.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtMyCustomer.Foreground = new SolidColorBrush(Colors.Gray);
        // }

        // //AddCustomer icon for enable module
        // private void AddCustomerIcon_Tapped(object sender, TappedRoutedEventArgs e)
        // {
        //     stackaddcustomer.IsHitTestVisible = true;
        //     //stackmessages.IsHitTestVisible = false;
        //     //stacktimeclock.IsHitTestVisible = false;
        //     //stackcalendar.IsHitTestVisible = false;
        //     //stackaddfollowup.IsHitTestVisible = false;
        //     //stackmycusomters.IsHitTestVisible = false;
        //     txtAddCustomer.Foreground = new SolidColorBrush(Colors.Black);
        //     txtTimeClock.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtCalendar.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtMessages.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtAddFollowUps.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtMyCustomer.Foreground = new SolidColorBrush(Colors.Gray);
        // }

        // //FollowUpIcon icon for enable module
        // private void FollowUpIcon_Tapped(object sender, TappedRoutedEventArgs e)
        // {
        //     stackaddfollowup.IsHitTestVisible = true;
        //     //stackaddcustomer.IsHitTestVisible = false;
        //     //stackmessages.IsHitTestVisible = false;
        //     //stacktimeclock.IsHitTestVisible = false;
        //     //stackcalendar.IsHitTestVisible = false;
        //     //stackmycusomters.IsHitTestVisible = false;
        //     txtAddFollowUps.Foreground = new SolidColorBrush(Colors.Black);
        //     txtTimeClock.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtCalendar.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtMessages.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtAddCustomer.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtMyCustomer.Foreground = new SolidColorBrush(Colors.Gray);
        // }

        // //MyCustomerIcon  for enable module
        // private void MyCustomerIcon_Tapped(object sender, TappedRoutedEventArgs e)
        // {
        //     stackmycusomters.IsHitTestVisible = true;
        //     //stackaddfollowup.IsHitTestVisible = false;
        //     //stackaddcustomer.IsHitTestVisible = false;
        //     //stackmessages.IsHitTestVisible = false;
        //     //stacktimeclock.IsHitTestVisible = false;
        //     //stackcalendar.IsHitTestVisible = false;
        //     txtMyCustomer.Foreground = new SolidColorBrush(Colors.Black);
        //     txtTimeClock.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtCalendar.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtMessages.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtAddCustomer.Foreground = new SolidColorBrush(Colors.Gray);
        //     txtAddFollowUps.Foreground = new SolidColorBrush(Colors.Gray);
        // }

        public static SolidColorBrush GetColorFromHexa(string hexaColor)
        {
            //show colors from hexa
            return new SolidColorBrush(
                Color.FromArgb(
                    Convert.ToByte(hexaColor.Substring(1, 2), 16),
                    Convert.ToByte(hexaColor.Substring(3, 2), 16),
                    Convert.ToByte(hexaColor.Substring(5, 2), 16),
                    Convert.ToByte(hexaColor.Substring(7, 2), 16)
                    )
                );
        }



        private void Children_Loaded(object sender, RoutedEventArgs e)
        {

            List<string> data = new List<string>();
            data.Add("Mark Fontaine");
            data.Add("Mark Fontaine2");
            data.Add("Mark Fontaine1");

            var comboBox = sender as ComboBox;

            comboBox.ItemsSource = data;
            comboBox.FontSize = 20;
            comboBox.FontWeight = FontWeights.Bold;
            comboBox.FontFamily = new FontFamily("Open Sans");
            comboBox.SelectedIndex = 0;



        }

        private void btnviewline_Click(object sender, RoutedEventArgs e)
        {
            string content = (sender as Button).Content.ToString();

            if ((btnviewline.Content).ToString() == "EDIT NOTE" && ((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem).EventType == "CALENDAR - NOTES")
            {

                editnotes = new Popup();
                // this.Background = new SolidColorBrush(Colors.Gray);
                EditNotes en = new EditNotes(((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem), content);

                var calendarService = CoreApp.Instance.GetServiceFactory().GetCalendarService();
                ////var gnote = CalendarNoteBuilder.Instance().ForEmployee(this.coreApp.CurrentUser.EmployeeId).WithNote("Hi there").FromStartDateTime(DateTime.Now).TillEndDateTime(DateTime.Now).ToEvent();                
                ////calendarService.AddNoteToCalendar(gnote);

                //var gnoteupdate = CalendarNoteBuilder.Instance().WithEventId(((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem).EventId).ForEmployee(this.coreApp.CurrentUser.EmployeeId).WithNote("Hi there update").FromStartDateTime(DateTime.Now).TillEndDateTime(DateTime.Now).ToEvent();
                //calendarService.UpdateCalendarNote(gnoteupdate);
                //////calendarService.DeleteCalendarNote(gnoteupdate);

                var currentPage = Window.Current.Content as Page;
                currentPage.Opacity = 0.4;
                currentPage.IsEnabled = false;

                //var rootFrame = new MasterPage();
                //rootFrame.Opacity = 0.4;
                //rootFrame.Tapped += new TappedEventHandler(EditNotePopupClose_Tapped);
                //rootFrame.ContentFrame.Navigate(typeof(Calendar));
                //Window.Current.Content = rootFrame;
                //Window.Current.Activate();
                //GridCalendar.Opacity = 0.2;
                //GridCalendar.Background = new SolidColorBrush(Colors.Black);
                editnotes.Child = en;
                editnotes.HorizontalOffset = Window.Current.Bounds.Width - 1500;
                editnotes.VerticalOffset = Window.Current.Bounds.Height - 800;
                editnotes.IsOpen = true;
                editnotes.Height = 1000;
                editnotes.Width = 700;
                editnotes.HorizontalAlignment = HorizontalAlignment.Right;
                editnotes.VerticalAlignment = VerticalAlignment.Center;
                editnotes.Margin = new Thickness(400, 200, 0, 0);
                //popup1.Closed += (s1, e1) =>
                //{

                //};
            }
            else
            {
                //get timeline data    
                grdTreeViewTimeline.RowDefinitions.Clear();
                grdTreeViewTimeline.ColumnDefinitions.Clear();
                grdTreeViewTimeline.Children.Clear();
                IServiceFactory factory = coreApp.GetServiceFactory();
                ICustomerRepository customerTimelineService = factory.GetCustomerRepository();
                int icustomerId = ((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem).CustomerId;
                var objTimeline = customerTimelineService.GetCustomerTimeLine(icustomerId);
                grdTreeViewTimeline.ColumnDefinitions.Add(new ColumnDefinition());
                grdTreeViewTimeline.ColumnDefinitions.Add(new ColumnDefinition());
                TextBlock objappointments = null;
                Line objhorizontalline = null;
                Line objVerticalLine = null;
                int k = 0;

                //row count has been initializing
                int rowsCount = 0;
                if (objTimeline != null)
                {
                    for (int i = 0; i < objTimeline.Count(); i++)
                    {

                        for (int j = 0; j < 2; j++)
                        {
                            //creating a row
                            grdTreeViewTimeline.RowDefinitions.Add(new RowDefinition());
                            grdTreeViewTimeline.RowDefinitions.Add(new RowDefinition() { Height = new GridLength(35) });


                            //creating a vertical line
                            objVerticalLine = new Line();
                            objVerticalLine.Stroke = new SolidColorBrush(Colors.LightGray);
                            objVerticalLine.StrokeThickness = 4;
                            objVerticalLine.Y1 = 25;
                            objVerticalLine.Y2 = 0;
                            objVerticalLine.Stretch = Stretch.UniformToFill;
                            objVerticalLine.Width = 50;
                            objVerticalLine.HorizontalAlignment = HorizontalAlignment.Center;
                            objVerticalLine.Margin = new Thickness(50, 0, 0, 0);
                            grdTreeViewTimeline.Children.Add(objVerticalLine);
                            Grid.SetRow(objVerticalLine, rowsCount);
                            Grid.SetColumn(objVerticalLine, 0);

                            rowsCount++;
                            j++;

                            //creating a horizontal line

                            if (objTimeline[i].ToString() == "View All")
                            {
                                objhorizontalline = new Line();
                                objhorizontalline.Stroke = new SolidColorBrush(Colors.Red);
                                objhorizontalline.StrokeThickness = 4;
                                objhorizontalline.X1 = 50;
                                objhorizontalline.X2 = 0;
                                objhorizontalline.Stretch = Stretch.Fill;
                                objhorizontalline.Width = 50;
                                objhorizontalline.HorizontalAlignment = HorizontalAlignment.Center;
                                objhorizontalline.Margin = new Thickness(50, 0, 0, 0);
                                grdTreeViewTimeline.Children.Add(objhorizontalline);
                                Grid.SetRow(objhorizontalline, rowsCount);
                                Grid.SetColumn(objhorizontalline, 0);

                            }
                            else
                            {
                                objhorizontalline = new Line();
                                objhorizontalline.Stroke = new SolidColorBrush(Colors.Orange);
                                objhorizontalline.StrokeThickness = 4;
                                objhorizontalline.X1 = 50;
                                objhorizontalline.X2 = 0;
                                objhorizontalline.Stretch = Stretch.Fill;
                                objhorizontalline.Width = 50;
                                objhorizontalline.HorizontalAlignment = HorizontalAlignment.Center;
                                objhorizontalline.Margin = new Thickness(50, 0, 0, 0);
                                grdTreeViewTimeline.Children.Add(objhorizontalline);
                                Grid.SetRow(objhorizontalline, rowsCount);
                                Grid.SetColumn(objhorizontalline, 0);
                            }

                            //textblock binding for get appointments
                            objappointments = new TextBlock();

                            objappointments.Name = k.ToString();
                            objappointments.Width = 146;
                            objappointments.TextWrapping = TextWrapping.Wrap;
                            objappointments.Tapped += new TappedEventHandler(Appointments_Tapped);
                            objappointments.HorizontalAlignment = HorizontalAlignment.Left;
                            objappointments.VerticalAlignment = VerticalAlignment.Center;
                            objappointments.Foreground = new SolidColorBrush(Colors.Gray);
                            objappointments.FontFamily = new FontFamily("Open Sans");
                            objappointments.FontSize = 16;
                            objappointments.SetValue(Grid.ColumnSpanProperty, 2);
                            objappointments.SetValue(Grid.RowProperty, 2);
                            objappointments.Text =
                           (objTimeline[i].ActivityDate.ToString("MMM dd") + '\n' + objTimeline[i].AppointmentType).Trim();
                            grdTreeViewTimeline.Children.Add(objappointments);
                            Grid.SetRow(objappointments, rowsCount);
                            Grid.SetColumn(objappointments, 1);
                            k++;
                            if (i == 0)
                            {
                                objappointments.FontWeight = FontWeights.Bold;
                            }
                        }
                        rowsCount++;
                    }

                    txtTimelineYear.Text = objTimeline[0].ActivityDate.ToString("yyyy");


                    if (objTimeline.FirstOrDefault().EventType == "INSTALL" || objTimeline.FirstOrDefault().EventType == "SALES APPT")
                    {
                        int ieventId = ((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem).EventId;
                        //get imagelist
                        IMediaService mediaService = new MediaService();
                        var img = mediaService.GetImagesForEvent(ieventId);

                        InstallAppointments objInstallAppointments = new InstallAppointments(objTimeline.FirstOrDefault(), img, ieventId);
                        UserControlInvoke.Children.Add(objInstallAppointments);
                        objappointments.FontWeight = FontWeights.Normal;
                    }
                }

                //show appropriate grid to shown
                CalendarView.Visibility = Visibility.Collapsed;
                TimelineView.Visibility = Visibility.Visible;
            }
        }

        private void DeleteTimeline_Tapped(object sender, TappedRoutedEventArgs e)
        {
            //remove my controls in grid
            foreach (UIElement control in grdTreeViewTimeline.Children)
            {
                grdTreeViewTimeline.Children.Remove(control);
            }
            //show appropriate grid to shown
            CalendarView.Visibility = Visibility.Visible;
            TimelineView.Visibility = Visibility.Collapsed;
        }


        //to get Selected appointments details
        private void Appointments_Tapped(object sender, TappedRoutedEventArgs e)
        {
            IServiceFactory factory = coreApp.GetServiceFactory();
            ICustomerRepository customerTimelineService = factory.GetCustomerRepository();
            int icustomerId = ((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem).CustomerId;
            int ieventid = ((XMobileWiz.Core.Domain.EventData)CalendarDetail.SelectedItem).EventId;
            var objSelectedTimeline = customerTimelineService.GetCustomerTimeLine(icustomerId).ToList();
            //get imagelist
            IMediaService mediaService = new MediaService();
            var img = mediaService.GetImagesForEvent(ieventid);

            TextBlock objtextblock = sender as TextBlock;
            int startIndex = Convert.ToInt32(objtextblock.Name);
            var index = objSelectedTimeline.ElementAt(startIndex);
            InstallAppointments objInstallAppointments = new InstallAppointments(index, img, ieventid);
            UserControlInvoke.Children.Add(objInstallAppointments);
            var textblocks = grdTreeViewTimeline.Children.OfType<TextBlock>().ToList();
            foreach (var textblockitems in textblocks)
            {
                textblockitems.FontWeight = FontWeights.Normal;
            }

            objtextblock.FontWeight = FontWeights.Bold;

        }


        //close my popup
        private void EditNotePopupClose_Tapped(object sender, TappedRoutedEventArgs e)
        {
            if (editnotes != null)
            {
                if (editnotes.IsOpen)
                {
                    editnotes.IsOpen = false;
                    var rootFrame = new MasterPage();
                    rootFrame.Background = new SolidColorBrush(Colors.Transparent);
                    rootFrame.Opacity = 1;
                    rootFrame.ContentFrame.Navigate(typeof(Calendar));
                    Window.Current.Content = rootFrame;
                    Window.Current.Activate();
                    // GridCalendar.Opacity = 1;
                    // GridCalendar.Background = new SolidColorBrush(Colors.Transparent);

                }
            }

        }
        //Add New Notes
        private void addNewNote_Tapped(object sender, TappedRoutedEventArgs e)
        {
            editnotes = new Popup();
            string content = (sender as Button).Content.ToString();
            string selecteddate = currentdatemonth.Text;
            // EditNotes en = new EditNotes(content);
            EditNotes en = new EditNotes(content, selecteddate);
            var rootFrame = new MasterPage();
            rootFrame.Opacity = 0.4;
            rootFrame.Tapped += new TappedEventHandler(EditNotePopupClose_Tapped);
            rootFrame.ContentFrame.Navigate(typeof(Calendar));
            Window.Current.Content = rootFrame;
            Window.Current.Activate();
            //GridCalendar.Opacity = 0.2;
            //GridCalendar.Background = new SolidColorBrush(Colors.Black);
            editnotes.Child = en;
            editnotes.HorizontalOffset = Window.Current.Bounds.Width - 1500;
            editnotes.VerticalOffset = Window.Current.Bounds.Height - 800;
            editnotes.IsOpen = true;
            editnotes.Height = 1000;
            editnotes.Width = 700;
            editnotes.HorizontalAlignment = HorizontalAlignment.Right;
            editnotes.VerticalAlignment = VerticalAlignment.Center;
            editnotes.Margin = new Thickness(400, 200, 0, 0);
        }
        private void loginSuccessOK_Tapped(object sender, Windows.UI.Xaml.Input.TappedRoutedEventArgs e)
        {
            //alertMessagepopup.Visibility = Visibility.Collapsed;
            GridCalendarSub.Opacity = 1;
            (App.Current as App).LoginStatus = true;
        }

        private void btn2_Tapped(object sender, TappedRoutedEventArgs e)
        {
            addfollowup = new Popup();
            AddFollowUp en = new AddFollowUp();
            var rootFrame = new MasterPage();
            rootFrame.Opacity = 0.4;
            //    rootFrame.Tapped += new TappedEventHandler(EditNotePopupClose_Tapped);
            rootFrame.ContentFrame.Navigate(typeof(Calendar));
            Window.Current.Content = rootFrame;
            Window.Current.Activate();
            addfollowup.Child = en;
            addfollowup.HorizontalOffset = Window.Current.Bounds.Width - 1500;
            addfollowup.VerticalOffset = Window.Current.Bounds.Height - 800;
            addfollowup.IsOpen = true;
            addfollowup.Height = 1500;
            addfollowup.Width = 900;
            addfollowup.HorizontalAlignment = HorizontalAlignment.Right;
            addfollowup.VerticalAlignment = VerticalAlignment.Center;
            addfollowup.Margin = new Thickness(400, 200, 0, 0);

        }
    }
}
