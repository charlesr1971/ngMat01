import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';

import { ReactiveFormsModule, FormsModule } from '@angular/forms';

import { DeviceDetectorModule } from 'ngx-device-detector';

import { AppComponent } from './app.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MyNavComponent } from './my-nav/my-nav.component';
import { LayoutModule } from '@angular/cdk/layout';
import { MatToolbarModule, MatButtonModule, MatSidenavModule, MatIconModule, MatListModule, MatGridListModule, MatCardModule, MatMenuModule, MatTableModule, MatPaginatorModule, MatSortModule, MatTreeModule, MatProgressBarModule, MatInputModule } from '@angular/material';
import { CdkTreeModule } from '@angular/cdk/tree';
import { MyDashboardComponent } from './my-dashboard/my-dashboard.component';
import { MyTableComponent } from './my-table/my-table.component';

import { FirstPageComponent } from './routes/first-page/first-page.component';
import { SecondPageComponent } from './routes/second-page/second-page.component';
import { ThirdPageComponent } from './routes/third-page/third-page.component';

import { HttpService } from './services/http/http.service';

import { RouterModule, Routes } from '@angular/router';
import { TreeDynamic } from './trees/tree-dynamic/tree-dynamic';
import { PathFormatPipe } from './pipes/path-format/path-format.pipe';

import { UploadModule } from './upload/upload.module';

import { DialogComponent } from './upload/dialog/dialog.component';

const appRoutes: Routes = [
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
    PathFormatPipe
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
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
    FormsModule, 
    ReactiveFormsModule,
    DeviceDetectorModule.forRoot()
  ],
  entryComponents: [DialogComponent], // Add the DialogComponent as entry component
  providers: [
    HttpService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
