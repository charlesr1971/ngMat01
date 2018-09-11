import {CollectionViewer, SelectionChange} from '@angular/cdk/collections';
import {FlatTreeControl} from '@angular/cdk/tree';
import {Component, Injectable, OnInit, Inject, ElementRef, ViewChild, Renderer2 } from '@angular/core';
import {BehaviorSubject, merge, Observable, Subject} from 'rxjs';
import { debounceTime, distinctUntilChanged } from "rxjs/operators";
import {map} from 'rxjs/operators';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { DeviceDetectorService } from 'ngx-device-detector';
import { DOCUMENT } from '@angular/common'; 

import { HttpService } from '../../services/http/http.service';
import { UploadService } from '../../upload/upload.service';

import { environment } from '../../../environments/environment';

declare var ease, TweenMax, Elastic: any;

/** Flat node with expandable and level information */
export class DynamicFlatNode {
  constructor(public item: string, public level = 1, public expandable = false,
              public isLoading = false, public alias: string) {}
}

/**
 * Database for dynamic data. When expanding a node in the tree, the data source will need to fetch
 * the descendants data from the database.
 */
@Injectable()
export class DynamicDatabase  {

  
  
  /* dataMap = new Map<string, string[]>([
    ['Fruits', ['Apple', 'Orange', 'Banana']],
    ['Vegetables', ['Tomato', 'Potato', 'Onion']],
    ['Apple', ['Fuji', 'Macintosh']],
    ['Onion', ['Yellow', 'White', 'Purple']]
  ]); */

  dataMap = new Map<string, string[]>();

  //rootLevelNodes: string[] = ['Fruits', 'Vegetables'];

  rootLevelNodes: string[] = ['//categories//objects', '//categories//nature', '//categories//other'];

  http: Observable<any>;

  httpService;

  constructor(httpService: HttpService) {
    
    this.httpService = httpService;
    this.fetchData();

  }

  fetchData() {
    this.http = this.httpService.fetchDirectoryTree().subscribe( (data: any) => {
      this.dataMap = new Map<string, string[]>(data);
      console.log(this.dataMap);
    });
  }

  /** Initial data from database */
  initialData(): DynamicFlatNode[] {
    return this.rootLevelNodes.map(name => new DynamicFlatNode(name, 0, true, false, this.pathFormat(name)));
  }

  getChildren(node: string): string[] | undefined {
    return this.dataMap.get(node);
    //return this.httpService.fetchDirectoryTree().subscribe( (data: any) => { data.get(node); });
  }

  isExpandable(node: string): boolean {
    return this.dataMap.has(node);
    //return this.httpService.fetchDirectoryTree().subscribe( (data: any) => { data.has(node); });
  }

  pathFormat(alias: string): any {
    let last:any = alias.split("//");
    last = Array.isArray(last) ? last[last.length-1] : alias;
    return last;
  }


}
/**
 * File database, it can build a tree structured Json object from string.
 * Each node in Json object represents a file or a directory. For a file, it has filename and type.
 * For a directory, it has filename and children (a list of files or directories).
 * The input will be a json object string, and the output is a list of `FileNode` with nested
 * structure.
 */
@Injectable()
export class DynamicDataSource {

  dataChange = new BehaviorSubject<DynamicFlatNode[]>([]);

  get data(): DynamicFlatNode[] { return this.dataChange.value; }
  set data(value: DynamicFlatNode[]) {
    this.treeControl.dataNodes = value;
    this.dataChange.next(value);
  }

  constructor(private treeControl: FlatTreeControl<DynamicFlatNode>,
              private database: DynamicDatabase) {}

  connect(collectionViewer: CollectionViewer): Observable<DynamicFlatNode[]> {
    this.treeControl.expansionModel.onChange!.subscribe(change => {
      if ((change as SelectionChange<DynamicFlatNode>).added ||
        (change as SelectionChange<DynamicFlatNode>).removed) {
        this.handleTreeControl(change as SelectionChange<DynamicFlatNode>);
      }
    });

    return merge(collectionViewer.viewChange, this.dataChange).pipe(map(() => this.data));
  }

  /** Handle expand/collapse behaviors */
  handleTreeControl(change: SelectionChange<DynamicFlatNode>) {
    if (change.added) {
      change.added.forEach(node => this.toggleNode(node, true));
    }
    if (change.removed) {
      change.removed.slice().reverse().forEach(node => this.toggleNode(node, false));
    }
  }

  /**
   * Toggle the node, remove from display list
   */
  toggleNode(node: DynamicFlatNode, expand: boolean) {
    const children = this.database.getChildren(node.item);
    const index = this.data.indexOf(node);
    if (!children || index < 0) { // If no children, or cannot find the node, no op
      return;
    }

    node.isLoading = true;

    setTimeout(() => {
      if (expand) {
        const nodes = children.map(name =>
          new DynamicFlatNode(name, node.level + 1, this.database.isExpandable(name), false, this.database.pathFormat(name)));
        this.data.splice(index + 1, 0, ...nodes);
      } else {
        let count = 0;
        for (let i = index + 1; i < this.data.length
          && this.data[i].level > node.level; i++, count++) {}
        this.data.splice(index + 1, count);
      }

      // notify the change
      this.dataChange.next(this.data);
      node.isLoading = false;
    }, 1000);
  }
}

/**
 * @title Tree with dynamic data
 */
@Component({
  selector: 'tree-dynamic',
  templateUrl: 'tree-dynamic.html',
  styleUrls: ['tree-dynamic.css'],
  providers: [DynamicDatabase]
})
export class TreeDynamic implements OnInit {

  @ViewChild('uploadedImageContainer') uploadedImageContainer;

  imagePath: string;
  selectedFile: File;
  directorySelected: string;
  treeForm: FormGroup;
  name: FormControl;
  maxNameLength: number = 20;
  title: FormControl;
  maxTitleLength: number = 40;
  description: FormControl;
  maxDescriptionLength: number = 140;
  formData = {};

  treeControl: FlatTreeControl<DynamicFlatNode>;
  dataSource: DynamicDataSource;
  getLevel = (node: DynamicFlatNode) => node.level;
  isExpandable = (node: DynamicFlatNode) => node.expandable;
  hasChild = (_: number, _nodeData: DynamicFlatNode) => _nodeData.expandable;
  isMobile: boolean = false;

  constructor(@Inject(DOCUMENT) document, 
    database: DynamicDatabase, 
    private http: HttpClient,
    private httpService: HttpService,
    private uploadService: UploadService,
    private renderer: Renderer2,
    public el: ElementRef,
    private deviceDetectorService: DeviceDetectorService
    ) {
    this.treeControl = new FlatTreeControl<DynamicFlatNode>(this.getLevel, this.isExpandable);
    this.dataSource = new DynamicDataSource(this.treeControl, database);
    this.dataSource.data = database.initialData();
    this.isMobile = this.deviceDetectorService.isMobile();
  }

  ngOnInit() {
    this.createFormControls();
    this.createForm();
    this.name.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(name => {
        console.log("name: ",name);
        this.formData['name'] = name;
      });

    this.title.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(title => {
        console.log("title: ",title);
        this.formData['title'] = title;
      });

      this.description.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(description => {
        console.log("description: ",description);
        this.formData['description'] = description;
      });

      this.uploadService.subscriptionImageUrl.subscribe( (data: any) => {
        console.log('tree.dynamic: data: ',data);
        const uploadedImageContainer = this.uploadedImageContainer.nativeElement;
        const img = this.renderer.createElement('img');
        this.renderer.setAttribute(img,'src',data);
        this.renderer.setAttribute(img,'id','uploadedImage');
        const uploadedImage = document.getElementById('uploadedImage');
        if(uploadedImage) {
          this.renderer.removeChild(uploadedImageContainer,uploadedImage);
          console.log('tree.dynamic: remove image');
        }
        
        this.renderer.appendChild(uploadedImageContainer,img);
        TweenMax.fromTo("#uploadedImage", 1, {scale:0, ease:Elastic.easeOut, opacity: 0}, {scale:1, ease:Elastic.easeOut, opacity: 1});
        console.log('tree.dynamic: add image');
        
        /* const img = '<img src="' + data + '" />';
        uploadedImageContainer.html(img); */
      });

  }

  createFormControls() {
    this.name = new FormControl("", Validators.required);
    this.title = new FormControl("", Validators.required);
    this.description = new FormControl("", Validators.required);
    this.name = new FormControl("", [
      Validators.required,
      Validators.minLength(1),
      Validators.maxLength(this.maxNameLength)
    ]);
    this.title = new FormControl("", [
      Validators.required,
      Validators.minLength(1),
      Validators.maxLength(this.maxTitleLength)
    ]);
    this.description = new FormControl("", [
      Validators.required,
      Validators.minLength(1),
      Validators.maxLength(this.maxDescriptionLength)
    ]);
  }

  createForm() {
    this.treeForm = new FormGroup({
      name: this.name,
      title: this.title,
      description: this.description
    });
  }

  addPath(event: any, item: string): void {
    const target = event.target || event.srcElement || event.currentTarget;
    console.log('addPath: target: ',target);
    /* const srcAttr = target.attributes.src;
    console.log('addPath: srcAttr: ',srcAttr);
    const src = srcAttr.nodeValue;
    console.log('addPath: src: ',src); */
    console.log('addPath: item: ',item);
    console.log('addPath: item: ',item);
    this.imagePath = item;
    this.formData['imagePath'] = this.imagePath;
    this.httpService.subjectImagePath.next(this.formData);
    this.directorySelected = this.imagePath;
    const gradeEl = document.getElementById('directory-' + this.pathFormat(this.imagePath));
    console.log('addPath: gradeEl: ',gradeEl);
    TweenMax.fromTo(gradeEl, 1, {scale:0, ease:Elastic.easeOut, opacity: 0, rotation: 1}, {scale:1, ease:Elastic.easeOut, opacity: 1, rotation: 359});
  }

  /* onFileChanged(event) {
    this.selectedFile = event.target.files[0];
    console.log('onFileChanged: this.selectedFile: ',this.selectedFile);
  }

  onUpload() {
    // upload code goes here
  } */

  previewImage(event) {
    this.selectedFile = event.target.files[0];
    console.log('onFileChanged: this.selectedFile: ',this.selectedFile);
    this.onUpload();
  }

  onUpload() {

    let fileExtension: any = this.selectedFile.type.split("/");
    fileExtension = Array.isArray(fileExtension) ? fileExtension[fileExtension.length-1] : "";

    const httpOptions = {
      headers: new HttpHeaders({
        'Image-path':  this.imagePath,
        'File-Extension': fileExtension
      })
    };

    this.http.post(environment.ajax_dir + '/upload-image.cfm', this.selectedFile, httpOptions).pipe(map(
      (res: Response) => {
        console.log(res);
        return res;
      })
    ).subscribe( (data: any) => {
      console.log('onUpload: data: ',data);
    });

  }

  pathFormat(value: any): any {
    let last = value.split("//");
    last = Array.isArray(last) ? last[last.length-1] : value;
    return last;
  }

  stringFromUTF8Array(data)
  {
    const extraByteMap = [ 1, 1, 1, 1, 2, 2, 3, 0 ];
    var count = data.length;
    var str = "";
    
    for (var index = 0;index < count;)
    {
      var ch = data[index++];
      if (ch & 0x80)
      {
        var extra = extraByteMap[(ch >> 3) & 0x07];
        if (!(ch & 0x40) || !extra || ((index + extra) > count))
          return null;
        
        ch = ch & (0x3F >> extra);
        for (;extra > 0;extra -= 1)
        {
          var chx = data[index++];
          if ((chx & 0xC0) != 0x80)
            return null;
          
          ch = (ch << 6) | (chx & 0x3F);
        }
      }
      
      str += String.fromCharCode(ch);
    }
    
    return str;
  }

}


/**  Copyright 2018 Google Inc. All Rights Reserved.
    Use of this source code is governed by an MIT-style license that
    can be found in the LICENSE file at http://angular.io/license */