# WIND FARM SITING

# setup -------------------------------------------------------------------

library(sf)
library(tmap)
library(shiny)
library(shinydashboard)
library(shinyBS)
library(shinycssloaders)
library(tidyverse)

tmap_mode('view')

source('source_script.R')

theme <- 
  theme(
    axis.title = element_text(
      face = 'bold.italic',
      size = 12),
    axis.text = element_text(size = 12),
    axis.ticks = element_line('#dcdcdc'),
    panel.background = element_rect('white'),
    panel.grid.major.y = element_line(colour = '#f0f0f0'),
    panel.grid.major.x = element_blank())

turbine_texas <- 
  sf$site %>% 
  st_transform(
    st_crs(raster$land)) %>% 
  filter(state == 'Texas') %>% 
  tm_shape(name = 'Wind Turbines') +
  tm_dots(
    clustering = TRUE,
    popup.vars = 
      c('ID' = 'case_id',
        'State' = 'state',
        'County' = 't_county',
        'FIPS code' = 't_fips',
        'Turbine capacity (MW)' = 't_cap',
        'Turbine hub height (m)'= 't_hh',
        'Turbine rotor diameter (m)' = 't_rd',
        'Turbine rotor swept area area (m2)' = 't_rsa',
        'Turbine total height (m)' = 't_ttlh',
        'Project' = 'p_name',
        'Project built year' = 'p_year'))

# set loader

options(
  spinner.color = "#0275D8", 
  spinner.color.background = "#ffffff", 
  spinner.size = 2)

# ui ----------------------------------------------------------------------

ui <- 
  bootstrapPage(
    
    # head
    
    tags$head(
      tags$link(
        rel = 'stylesheet',
        href = 'style.css'),
      tags$link(
        rel = "stylesheet", 
        href = 'https://fonts.googleapis.com/css2?family=Lato:wght@400;700;900&display=swap'),
    ),
    
    # body
    
    navbarPage(
      title = span(
        'Wind Farm Siting', 
        style = 'font-size: 20px; font-weight: 700;'),
      position = 'fixed-top',
      collapsible = TRUE,
      fluid = TRUE,
      inverse = TRUE,
      footer = 
        div(
          class = 'footer',
          p('A working project by Xinyu Zheng (zheng.xinyu.zx@gmail.com)')),
      
      # ui research proposal ----------------------------------------------------
      
      tabPanel(
        'About',
        class = 'about_panel',
        h3('About'),
        br(),
        
        # Intro
        
        bsCollapse(
          multiple = TRUE,
          open = 'Introduction',
          bsCollapsePanel(
            title = 
              span(
                'Introduction',
                style = 'font-size: 18px; font-weight: 700'),
            p("Sustainability has been at the top of the global agenda. In 2022, nations gathered together again in the 27th Conference of the Parties of the UNFCCC (COP27) to act towards the goal of the Paris Agreement - limit global warming to well below 2, preferably to 1.5 degrees Celsius. To approach this goal under the Paris Agreement, 196 countries set their emission reduction targets and are legally obligated to them. In the U.S., the Biden administration set the target of reaching net zero emissions economy-wide by no later than 2050. Renewable energy development was regarded as one of the essential strategies to commit to this target. Directed by Executive Order 14008, Tackling the Climate Crisis at Home and Abroad, the Department of Interior set its goal to increase 30 gigawatts of offshore wind by 2030 and at least 25 gigawatts of onshore renewable energy by 2025. Focusing on onshore wind energy only, this project presents the deployment and distribution of onshore wind turbines. In the DATABASE tab, users are able to explore the wind farm sitting on an interactive map and download the wind turbine data."),
            p("This project also examines the determinants of wind farm siting, taking Texas, the home of over 25% of wind energy capacity in the U.S., as an illustrative example. Intensive research has modeled the siting of wind farms considering their technical and economic potentials. Technically they measured the wind speed and land suitability to exclude urban areas, ecological areas, historical sites, roads, and railways345. Economically, they considered the assets, installation costs, and transmission grid distance678. Besides, some count the public acceptance of wind farms as a factor affecting wind farm siting. Earlier research raised the not-in-my-backyard theory9, which explains the local resistance to wind farm construction by avoidance of costs. The later study developed a new idea called the please-in-my-backyard framework, in which communities welcome wind farms for the income the new project brings10. Another stream of literature considers factors beyond the cost-benefit analysis1112. They associated the public acceptance of wind farms with perceived fairness. They argued that local acceptance is high when communities can participate in the decision-making process, known as procedural justice.")
          ),
          
          # Data
          
          bsCollapsePanel(
            title = 
              span(
                'Data',
                style = 'font-size: 18px; font-weight: 700'),
            withTags(
              ul(
                li(
                  a(
                    href = 'https://eerscmap.usgs.gov/uswtdb/data/',
                    'The site-level wind turbine data from The United States Wind Turbine Database (USWTDB)16')),
                li(
                  a(
                    href= 'https://www.nrel.gov/gis/wind-resource-maps.html',
                    'The monitor-level wind speed data in raster file from the NREL (at 60, 80,100 meters above surface)12131415')),
                li(
                  a(
                    href= 'https://hifld-geoplatform.opendata.arcgis.com/datasets/geoplatform::electric-power-transmission-lines/about',
                    'The electric power transmission lines from the Homeland Infrastructure Foundation Level Database (HIFLD)1617181920')),
                li(
                  a(
                    href= 'https://www.mrlc.gov/data/nlcd-2019-land-cover-conus',
                    'The 2019 National Land Cover Database (NLCD) in raster file from the Multi-Resolution Land Characteristics Consortium21')),
                li(
                  a(
                    href = 'https://www.census.gov/data/developers/data-sets/acs-5year.html',
                    "The median household income, the proportion of the population gaining bachelor's degree, the employment rate at the county level from 2020 5-year ACS of the Census Bureau")))),
            span(
              p("Shapefiles were simplified, and the high-resolution raster files were aggregated into lower-resolution raster files to increase the processing speed"),
              style = 'color:#c1c1c1;font-size:15px;')
          ),
          
          # Reference
          
          bsCollapsePanel(
            title = 
              span(
                'Reference',
                style = 'font-size: 18px; font-weight: 700'),
            withTags(
              ol(
                li("Mai, T.; Lopez, A.; Mowers, M.; Lantz, E. Interactions of Wind Energy Project Siting, Wind Resource Potential, and the Evolution of the U.S. Power System. Energy 2021, 223, 119998. https://doi.org/10.1016/j.energy.2021.119998."),
                li("Lopez, A.; Mai, T.; Lantz, E.; Harrison-Atlas, D.; Williams, T.; Maclaurin, G. Land Use and Turbine Technology Influences on Wind Potential in the United States. Energy 2021, 223, 120044. https://doi.org/10.1016/j.energy.2021.120044."),
                li("Janke, J. R. Multicriteria GIS Modeling of Wind and Solar Farms in Colorado. Renewable Energy 2010, 35 (10), 2228???2234. https://doi.org/10.1016/j.renene.2010.03.014."),
                li("Brown, A.; Beiter, P.; Heimiller, D.; Davidson, C.; Denholm, P.; Melius, J.; Lopez, A.; Hettinger, D.; Mulcahy, D.; Porro, G. Estimating Renewable Energy Economic Potential in the United States. Methodology and Initial Results; NREL/TP-6A20-64503; National Renewable Energy Lab. (NREL), Golden, CO (United States), 2016. https://doi.org/10.2172/1215323. "),
                li("van Haaren, R.; Fthenakis, V. GIS-Based Wind Farm Site Selection Using Spatial Multi-Criteria Analysis (SMCA): Evaluating the Case for New York State. Renewable and Sustainable Energy Reviews 2011, 15 (7), 3332???3340. https://doi.org/10.1016/j.rser.2011.04.010. "),
                li("Kelleher, J.; Ringwood, J. V. A Computational Tool for Evaluating the Economics of Solar and Wind Microgeneration of Electricity. Energy 2009, 34 (4), 401-409. https://doi.org/10.1016/j.energy.2008.10.009."),
                li("Dear, M. Understanding and Overcoming the NIMBY Syndrome. Journal of the American Planning Association 1992, 58 (3), 288-300. https://doi.org/10.1080/01944369208975808."),
                li("Guo, Y.; Ru, P.; Su, J.; Anadon, L. D. Not in My Backyard, but Not Far Away from Me: Local Acceptance of Wind Power in China. Energy 2015, 82, 722-733. https://doi.org/10.1016/j.energy.2015.01.082."),
                li("Liebe, U.; Bartczak, A.; Meyerhoff, J. A Turbine Is Not Only a Turbine: The Role of Social Context and Fairness Characteristics for the Local Acceptance of Wind Power. Energy Policy 2017, 107, 300-308. https://doi.org/10.1016/j.enpol.2017.04.043.") ,
                li("Wolsink, M. Wind Power Implementation: The Nature of Public Attitudes: Equity and Fairness Instead of 'backyard Motives.' Renewable and Sustainable Energy Reviews 2007, 11 (6), 1188-1207. https://doi.org/10.1016/j.rser.2005.10.005."),
                li('Draxl, C., B.M. Hodge, A. Clifton, and J. McCaa. 2015. Overview and Meteorological Validation of the Wind Integration National Dataset Toolkit (Technical Report, NREL/TP-5000-61740). Golden, CO: National Renewable Energy Laboratory.'),
                li('Draxl, C., B.M. Hodge, A. Clifton, and J. McCaa. 2015. "The Wind Integration National Dataset (WIND) Toolkit." Applied Energy 151: 355366.'),
                li('Lieberman-Cribbin, W., C. Draxl, and A. Clifton. 2014. Guide to Using the WIND Toolkit Validation Code (Technical Report, NREL/TP-5000-62595). Golden, CO: National Renewable Energy Laboratory.'),
                li('King, J., A. Clifton, and B.M. Hodge. 2014. Validation of Power Output for the WIND Toolkit (Technical Report, NREL/TP-5D00-61714). Golden, CO: National Renewable Energy Laboratory.'),
                li('Hoen, B.D., Diffendorfer, J.E., Rand, J.T., Kramer, L.A., Garrity, C.P., and Hunt, H.E., 2018, United States Wind Turbine Database v5.2 (October 12, 2022): U.S. Geological Survey, American Clean Power Association, and Lawrence Berkeley National Laboratory data release, https://doi.org/10.5066/F7TX3DN0.'),
                li("Dewitz, J., and U.S. Geological Survey, 2021, National Land Cover Database (NLCD) 2019 Products (ver. 2.0, June 2021): U.S. Geological Survey data release, https://doi.org/10.5066/P9KZCM54"),
                li('Wickham, J., Stehman, S.V., Sorenson, D.G., Gass, L., and Dewitz, J.A., 2021, Thematic accuracy assessment of the NLCD 2016 land cover for the conterminous United States: Remote Sensing of Environment, v. 257, art. no. 112357, at https://doi.org/10.1016/j.rse.2021.112357'),
                li('Homer, Collin G., Dewitz, Jon A., Jin, Suming, Xian, George, Costello, C., Danielson, Patrick, Gass, L., Funk, M., Wickham, J., Stehman, S., Auch, Roger F., Riitters, K. H., Conterminous United States land cover change patterns 2001-2016 from the 2016 National Land Cover Database: ISPRS Journal of Photogrammetry and Remote Sensing, v. 162, p. 184-199, at https://doi.org/10.1016/j.isprsjprs.2020.02.019'),
                li('Jin, Suming, Homer, Collin, Yang, Limin, Danielson, Patrick, Dewitz, Jon, Li, Congcong, Zhu, Z., Xian, George, Howard, Danny, Overall methodology design for the United States National Land Cover Database 2016 products: Remote Sensing, v. 11, no. 24, at https://doi.org/10.3390/rs11242971'),
                li('Yang, L., Jin, S., Danielson, P., Homer, C., Gass, L., Case, A., Costello, C., Dewitz, J., Fry, J., Funk, M., Grannemann, B., Rigge, M. and G. Xian. 2018. A New Generation of the United States National Land Cover Database: Requirements, Research Priorities, Design, and Implementation Strategies, ISPRS Journal of Photogrammetry and Remote Sensing, 146, pp.108-123.')))
          )
        )
      ),
      
      # ui database -------------------------------------------------------------
      
      tabPanel(
        'Database',
        h3('The United States Wind Turbine Database'),
        br(),
        
        # Widgets
        
        div(
          class = 'database_widgets_panel',
          div(
            class = 'widgets',
            selectInput(
              inputId = 'select_state',
              label = 'State',
              choice = c('Show all',
                         sf$state$NAME))),
          div(
            class = 'widgets',
            sliderInput(
              inputId = 'slider_tcap',
              label = 'Capacity (MW)',
              min = 50,
              max = 4050,
              value = c(50, 4050),
              step = 100,
              ticks = FALSE)
          ),
          div(
            class = 'widgets',
            sliderInput(
              inputId = 'slider_hh',
              label = 'Hub Height (m)',
              min = 22,
              max = 137,
              value = c(22, 137),
              step = 20,
              ticks = FALSE))
        ),
        br(),
        
        div(
          class = 'database_statistics_map_panel',
          
          # Statistic panel
          
          div(
            class = 'statistics_panel',
            span(
              h4('Statistics'), 
              style = 'color:#045a8d; font-weight:bold;'),
            p(textOutput('stat_turbine_number')),
            p(textOutput('stat_total_capacity')),
            p(textOutput('stat_avg_hub_height')),
            p(textOutput('stat_avg_rotor_diameter')),
            p(textOutput('stat_avg_total_height')),
            plotOutput(
              outputId = 'plot_cap', 
              height = '200px', 
              width = '100%')),
          
          # Present the tmap
          
          div(
            class = 'map_panel',
            tmapOutput(outputId ='map_turbine'))
        ),
        br(),
        
        
        # Data
        
        fluidRow(
          class = 'database_datatable_panel',
          tabBox(
            width = 12,
            side = 'left',
            tabPanel(
              'Wind Turbine Sites',
              downloadButton(
                class = 'button_download',
                outputId = 'site_download',
                label = "Download the wind turbine site data"),
              dataTableOutput(
                outputId = 'table_site')),
            tabPanel(
              'Wind Turbine Projects',
              downloadButton(
                class = 'button_download',
                outputId = 'project_download',
                label = "Download the wind turbine project data"),
              dataTableOutput(
                outputId = 'table_project'))
          )
        )
      ),
      
      navbarMenu(
        'What Determine the Wind Farm Siting - Texas Example',
        
        # texas wind potential ----------------------------------------------------
        
        tabPanel(
          'Wind Speed',
          h3('Does wind farm siting consider wind speed?'),
          br(),
          sidebarLayout(
            sidebarPanel(
              height = 600,
              span(
                p('As the wind speed varies across heights above the surface, wind turbines are plotted with a wind speed corresponding to their hub heights. Precisely, wind turbines with hub height below 70 meters, between 70 meters and 90 meters, and above 90 meters are mapped with wind speed raster at 60, 80, and 100 meters above the surface, respectively.'),
                style = 'color:#045a8d;'),
              br(),
              radioButtons(
                "radio_height",
                label = 
                  span(
                    "Select the height above the surface",
                    style = 'font-weight: 700; font-size: 18px'),
                choices = list('60 meters', 
                               '80 meters', 
                               '100 meters'),           
                selected = '60 meters')),
            mainPanel(
              tmapOutput(outputId = 'map_wind_speed'))
          )
        ),
        
        # texas power grid --------------------------------------------------------
        
        tabPanel(
          'Distance to the Power Grid',
          h3('Does wind farm siting consider the distance to electricity transmission lines?'),
          tmapOutput(outputId = 'map_power_grid')
        ),
        
        
        # texas land cover --------------------------------------------------------
        
        tabPanel(
          'Land Cover',
          h3('Does wind farm siting consider the type of land cover?'),
          tmapOutput(outputId = 'map_land_cover')
        ),
        
        
        # texas demographic features ----------------------------------------------
        
        tabPanel(
          'Demographic Features',
          h3('Does wind farm siting consider demographic features?'),
          tmapOutput(outputId = 'map_demographic_features')
        )
      )
    )
  )

# server ------------------------------------------------------------------

server <- 
  function(input, output){
    
    # reactive items ---------------------------------------------------------
    
    # Reactive term for the state bbox in the map
    
    bbox_by_state <- 
      reactive(
        if (input$select_state == 'Show all') {
          sf$state %>% 
            st_bbox()
        } else {
          sf$state %>% 
            filter(NAME == input$select_state) %>% 
            st_bbox()
        })
    
    # Reactive term for the range of turbine capacity in the map 
    
    site_filter <-
      reactive(
        sf$site %>% 
          filter(
            between(
              t_cap, 
              input$slider_tcap[1], 
              input$slider_tcap[2]),
            between(
              t_hh,
              input$slider_hh[1],
              input$slider_hh[2])))
    
    # Reactive term for the wind turbine database
    
    turbine_table_by_state <- 
      reactive(
        if (input$select_state == 'Show all') {
          site_filter() 
        } else {
          site_filter() %>% 
            filter(state == input$select_state)
        })
    
    project_table_by_state <- 
      reactive(
        if (input$select_state == 'Show all') {
          sf$project %>% 
            filter(
              p_name %in% 
                {turbine_table_by_state() %>% 
                    pull(p_name) %>% 
                    unique()})
        } else {
          sf$project %>% 
            filter(
              p_name %in% 
                {turbine_table_by_state() %>% 
                    pull(p_name) %>% 
                    unique()})
        })
    
    # Reactive term for wind speed
    
    wind_speed <- 
      reactive(
        if (input$radio_height == '60 meters') {
          raster$wind_60
        } else if (input$radio_height == '80 meters') {
          raster$wind_80
        } else {
          raster$wind_100
        })
    
    # Reactive term for wind turbines in wind speed map
    
    site_wind_speed <- 
      reactive(
        if (input$radio_height == '60 meters') {
          sf$site %>% 
            filter(t_hh < 70)
        } else if (input$radio_height == '80 meters') {
          sf$site %>% 
            filter(t_hh >= 70,
                   t_hh < 90)
        } else {
          sf$site %>% 
            filter(t_hh >= 90)
        })
    
    # render output -----------------------------------------------------------
    
    
    # output: database --------------------------------------------------------
    
    # Wind turbines map output
    
    output$map_turbine <- 
      renderTmap(
        tm_basemap(
          c('OpenStreetMap',
            'Esri.WorldImagery')) +
          site_filter() %>% 
          tm_shape('Wind Turbine Sites') +
          tm_dots(
            clustering = TRUE,
            popup.vars = 
              c('ID' = 'case_id',
                'State' = 'state',
                'County' = 't_county',
                'FIPS code' = 't_fips',
                'Turbine capacity (MW)' = 't_cap',
                'Turbine hub height (m)'= 't_hh',
                'Turbine rotor diameter (m)' = 't_rd',
                'Turbine rotor swept area area (m2)' = 't_rsa',
                'Turbine total height (m)' = 't_ttlh',
                'Project' = 'p_name',
                'Project built year' = 'p_year')) +
          tm_view(bbox = bbox_by_state()))
    
    # Statistics
    
    output$stat_turbine_number <- 
      renderText(
        paste(
          'Number of Turbines:',
          turbine_table_by_state() %>%
            count() %>% 
            pull(n)))
    
    output$stat_total_capacity <- 
      renderText(
        paste(
          'Total Capacity (MW):',
          turbine_table_by_state() %>%
            pull(t_cap) %>% 
            sum(na.rm = TRUE)))
    
    output$stat_avg_hub_height <- 
      renderText(
        paste(
          'Average Hub Height (m):',
          turbine_table_by_state() %>%
            pull(t_hh) %>% 
            mean(na.rm = TRUE)))
    
    output$stat_avg_rotor_diameter <- 
      renderText(
        paste(
          'Average Rotor Diameter (m):',
          turbine_table_by_state() %>%
            pull(t_rd) %>% 
            mean(na.rm = TRUE)))
    
    output$stat_avg_total_height <- 
      renderText(
        paste(
          'Average Total Height (m):',
          turbine_table_by_state() %>%
            pull(t_ttlh) %>% 
            mean(na.rm = TRUE)))
    
    # Plot capacity histogram
    
    output$plot_cap <- 
      renderPlot(
        turbine_table_by_state() %>% 
          ggplot(
            aes(x = t_cap)) +
          geom_histogram(
            bins = 50,       
            fill = '#4d9cc7',
            color = '#4d9cc7') +
          labs(
            x = 'Turbine Capacity (MW)') +
          theme)
    
    # Detailed table output
    
    output$table_site <- 
      renderDataTable(
        turbine_table_by_state() %>% 
          st_drop_geometry() %>% 
          rename(
            `case id` = case_id,
            `county` = t_county,
            `geoid` = t_fips,
            `project name` = p_name,
            `project operation year` = p_year,
            `turbine rated capacity (MW)` = t_cap,
            `tubrine hub height (m)` = t_hh,
            `turbine rotor diameter (m)` = t_rd,
            `turbine rotor swept area (m2)` = t_rsa,
            `turbine total height (m)` = t_ttlh))
    
    output$table_project <- 
      renderDataTable(
        project_table_by_state() %>% 
          st_drop_geometry() %>% 
          rename(
            `project name` = p_name,
            `project operation year` = p_year,
            `number of turbines` = p_tnum,
            `cumulative capacity of turbines (MW)` = p_cap))
    
    output$site_download <- 
      downloadHandler(
        filename = 'wind_turbine_site_data.csv',
        content = function(file_path) {
          write_csv(turbine_table_by_state(), file_path)
        }
      )
    
    output$project_download <- 
      downloadHandler(
        filename = 'wind_turbine_project_data.csv',
        content = function(file_path) {
          write_csv(project_table_by_state(), file_path)
        }
      )
    
    # output: wind speed ------------------------------------------------------
    
    output$map_wind_speed <- 
      renderTmap(
        tm_basemap(
          c('OpenStreetMap',
            'Esri.WorldImagery')) +
          wind_speed() %>% 
          tm_shape(name = 'Wind Speed') +
          tm_raster(
            title = 'Wind Speed (Mwh)',
            style = 'cont',
            palette = '-viridis',
            alpha = 0.9) +
          site_wind_speed() %>% 
          filter(state == 'Texas') %>% 
          st_transform(
            st_crs(
              wind_speed())) %>% 
          tm_shape(name = 'Wind Turbines') +
          tm_dots(
            clustering = TRUE,
            popup.vars = 
              c('ID' = 'case_id',
                'State' = 'state',
                'County' = 't_county',
                'FIPS code' = 't_fips',
                'Turbine capacity (MW)' = 't_cap',
                'Turbine hub height (m)'= 't_hh',
                'Turbine rotor diameter (m)' = 't_rd',
                'Turbine rotor swept area area (m2)' = 't_rsa',
                'Turbine total height (m)' = 't_ttlh',
                'Project' = 'p_name',
                'Project built year' = 'p_year')))
    
    # output: power grid ------------------------------------------------------
    
    output$map_power_grid <- 
      renderTmap(
        tm_basemap(
          c('OpenStreetMap',
            'Esri.WorldImagery')) +
          sf$grid %>% 
          st_transform(
            st_crs(raster$land)) %>% 
          tm_shape(name = 'Power Grid') +
          tm_lines(
            col = 'STATUS',
            title.col = 'Status',
            lwd = 2,
            labels = 
              c('In Service',
                'Inactive',
                'Not Available',
                'Proposed'),
            palette = 
              c('#5aa68b',
                '#f5bb47',
                '#606060',
                '#a94faa'),
            popup.format = 
              list(suffix = 'm'),
            popup.vars = 
              c('Global ID' = 'GlobalID',
                "Length" = 'SHAPE__Length')) +
          turbine_texas)
    
    
    # output: land cover ------------------------------------------------------
    
    output$map_land_cover <- 
      renderTmap(
        tm_basemap(
          c('OpenStreetMap',
            'Esri.WorldImagery')) +
          raster$land %>% 
          tm_shape(name = 'Land Cover') +
          tm_raster(
            title = 'Land Cover Category',
            style = 'cat',
            labels =
              c(
                'Unclassfied',
                # 'Open Water',
                # 'Perennial Snow/Ice',
                'Developed, Open Space',
                'Developed, Low Intensity',
                'Developed, Medium Intensit',
                'Developed, High Intensity',
                'Barren Land',
                'Deciduous Forest',
                'Evergreen Fores',
                'Mixed Forest',
                'Shrub/Scrub',
                'Herbaceous',
                'Hay/Pasture',
                'Cultivated Crops',
                'Woody Wetlands',
                'Emergent Herbaceous Wetlands'),
            palette =
              c(
                '#466b9f',
                # '#d1def8',
                # '#dec5c5',
                '#d98c82',
                '#eb0000',
                '#ab0000',
                '#b3ac9f',
                '#68ab5f',
                '#1c5f2c',
                '#b5c58f',
                '#ccb879',
                '#dfdfc2',
                '#dcd939',
                '#ab6c28',
                '#b8d9eb',
                '#6c9fb8')
          ) +
          turbine_texas)
    
    
    # output: demographic features --------------------------------------------
    
    output$map_demographic_features <- 
      renderTmap(
        tm_basemap(
          c('OpenStreetMap',
            'Esri.WorldImagery')) +
          sf$demography %>% 
          st_transform(
            st_crs(raster$land)) %>% 
          tm_shape(name = 'Median Household Income') +
          tm_polygons(
            col = 'median_household_income',
            title = 'Median Household Income',
            palette = '-Spectral',
            popup.format = 
              list(prefix = '$'),
            popup.vars = 
              c('County' = 'county',
                'Median Household Income' = 'median_household_income')) +
          sf$demography %>% 
          tm_shape(name = "Proportion of the Population Having Bachelor's Degree") +
          tm_polygons(
            col = 'bachelor_rate',
            title = "Proportion of the Population Having Bachelor's Degree",
            palette = '-Spectral',
            popup.vars = 
              c('County' = 'county',
                "Proportion of the Population Having Bachelor's Degree" = 'bachelor_rate')) +
          sf$demography %>% 
          tm_shape(name = 'Employment Rate') +
          tm_polygons(
            col = 'employment_rate',
            title = 'Employment Rate',
            palette = '-Spectral',
            popup.vars = 
              c('County' = 'county',
                'Employment Rate' = 'employment_rate')) +
          turbine_texas)
    
  }

# knit and run the app ----------------------------------------------------

shinyApp(ui, server)
