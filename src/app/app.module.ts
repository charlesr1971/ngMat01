import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule, HttpClientJsonpModule } from '@angular/common/http';
import { ReactiveFormsModule, FormsModule } from '@angular/forms';
import { DeviceDetectorModule } from 'ngx-device-detector';
import { ImageLazyLoadModule } from './image-lazy-load/image-lazy-load.module';
import { LightboxModule } from 'angular2-lightbox';
import { UploadModule } from './upload/upload.module';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { LayoutModule } from '@angular/cdk/layout';
import { MatToolbarModule, MatButtonModule, MatSidenavModule, MatIconModule, MatListModule, MatGridListModule, MatCardModule, MatMenuModule, MatTableModule, MatPaginatorModule, MatSortModule, MatTreeModule, MatProgressBarModule, MatInputModule, MatSelectModule } from '@angular/material';
import { CdkTreeModule } from '@angular/cdk/tree';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
//import { ShareModule } from '@ngx-share/core';
import { ShareButtonsModule } from '@ngx-share/buttons';

import { AppComponent } from './app.component';
import { MyNavComponent } from './my-nav/my-nav.component';
import { MyDashboardComponent } from './my-dashboard/my-dashboard.component';
import { MyTableComponent } from './my-table/my-table.component';
import { FirstPageComponent } from './routes/first-page/first-page.component';
import { SecondPageComponent } from './routes/second-page/second-page.component';
import { ThirdPageComponent } from './routes/third-page/third-page.component';
import { DialogComponent } from './upload/dialog/dialog.component';
import { ImagesComponent } from './images/images.component';
import { ImageComponent } from './image/image.component';

import { HttpService } from './services/http/http.service';
import { UtilsService } from './services/utils/utils.service';
import { CookieService } from 'ngx-cookie-service';
import { RouterModule, Routes } from '@angular/router';
import { TreeDynamic } from './trees/tree-dynamic/tree-dynamic';
import { PathFormatPipe } from './pipes/path-format/path-format.pipe';
import { FileSizePipe } from './pipes/file-size/file-size.pipe';
import { InfiniteScrollerDirective } from './directives/infinite-scroller/infinite-scroller.directive';

const appRoutes: Routes = [
  { path: '', component: FirstPageComponent },
  { path: 'first-page', component: FirstPageComponent },
  { path: 'second-page', component: SecondPageComponent },
  { path: 'third-page', component: ThirdPageComponent }
];

@NgModule({
  declarations: [
    AppComponent,
    MyNavComponent,
    MyDashboardComponent,
    MyTableComponent,
    FirstPageComponent,
    SecondPageComponent,
    ThirdPageComponent,
    TreeDynamic,
    PathFormatPipe,
    ImagesComponent,
    ImageComponent,
    FileSizePipe,
    InfiniteScrollerDirective
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    HttpClientJsonpModule,
    LayoutModule,
    MatToolbarModule,
    MatButtonModule,
    MatSidenavModule,
    MatIconModule,
    MatListModule,
    MatGridListModule,
    MatCardModule,
    MatMenuModule,
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    RouterModule.forRoot(appRoutes),
    CdkTreeModule,
    MatTreeModule,
    MatProgressBarModule,
    UploadModule,
    MatInputModule,
    MatSelectModule,
    FormsModule, 
    ReactiveFormsModule,
    DeviceDetectorModule.forRoot(),
    ImageLazyLoadModule,
    LightboxModule,
    FontAwesomeModule,
    //ShareModule.forRoot(),
    ShareButtonsModule.forRoot()
  ],
  entryComponents: [DialogComponent], // Add the DialogComponent as entry component
  providers: [
    HttpService,
    UtilsService,
    CookieService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
