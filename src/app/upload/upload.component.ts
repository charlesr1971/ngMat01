import { Component } from '@angular/core';
import { MatDialog } from '@angular/material';
import { DialogComponent } from './dialog/dialog.component';
import { UploadService } from './upload.service';
import { HttpService } from '../services/http/http.service';

@Component({
  selector: 'app-upload',
  templateUrl: './upload.component.html',
  styleUrls: ['./upload.component.css']
})
export class UploadComponent {

  isValid: boolean = false;

  constructor(public dialog: MatDialog, public uploadService: UploadService,
    private httpService: HttpService) {
      this.httpService.subscriptionImagePath.subscribe( (data: any) => {
        console.log('upload.service: data: ',data);
        if(data['imagePath'] != '' && data['name'] != '' && data['title'] != '') {
          this.isValid = true;
        }
      });
    }

  public openUploadDialog() {
    let dialogRef = this.dialog.open(DialogComponent, { width: '50%', height: '50%' });
  }

}
